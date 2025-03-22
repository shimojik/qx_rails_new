module Client
  class QxAiApiClient
    # 環境変数から基本URLを読み込み、パスを追加
    BASE_URL = "#{ENV['QX_API_URL']}"
    
    def initialize
      @api_key = ENV['QX_API_KEY']
      @polling_interval = ENV.fetch('QX_API_POLLING_INTERVAL', 10).to_i # ポーリング間隔（秒）
    end

    # 同期リクエストを送信して結果を返す
    def run_request(service:, params:, polling_interval: nil)
      polling_interval ||= @polling_interval
      Rails.logger.info("QX API 同期処理開始: service=#{service}")
      Rails.logger.debug("QX API リクエストパラメータ詳細: #{params.inspect}")
      
      # リクエストボディを作成
      request_body = { "body" => params["body"] }
      Rails.logger.debug("QX API リクエストボディ詳細: #{request_body.inspect}")
      
      begin
        # 1. リクエストを送信
        Rails.logger.info("QX API リクエスト送信開始: service=#{service}")
        response = connection.post("#{BASE_URL}/projects/df/#{service}") do |req|
          req.headers['X-API-Key'] = @api_key
          req.headers['Content-Type'] = 'application/json'
          req.body = request_body.to_json
        end
        
        Rails.logger.info("QX API レスポンス受信: status=#{response.status}")
        Rails.logger.debug("QX API レスポンス詳細: body=#{response.body.inspect}")
        
        if response.status == 200 || response.status == 202
          result = response.body
          request_id = result["request_id"]
          Rails.logger.info("QX API リクエストID取得成功: request_id=#{request_id}, status=#{result['status']}")
          
          # 2. 処理が完了するまでポーリング
          max_retries = 12
          retry_count = 0
          
          while retry_count < max_retries
            Rails.logger.info("QX API ポーリング実行: request_id=#{request_id}, 試行回数=#{retry_count+1}/#{max_retries}")
            
            poll_response = connection.get("#{BASE_URL}/results/#{request_id}") do |req|
              req.headers['X-API-Key'] = @api_key
            end
            
            Rails.logger.debug("QX API ポーリングレスポンス詳細: status=#{poll_response.status}, body=#{poll_response.body.inspect}")
            
            if poll_response.status == 200
              # Faradayレスポンスのボディは既にJSONパースされている場合があるため、
              # レスポンスの型を確認してから適切に処理する
              poll_result = if poll_response.body.is_a?(String)
                JSON.parse(poll_response.body)
              else
                poll_response.body
              end
              Rails.logger.info("QX API ポーリング結果: request_id=#{request_id}, status=#{poll_result['status']}")
              
              case poll_result["status"]
              when "completed"
                # 処理完了 - 結果を返す
                Rails.logger.info("QX API 処理完了: request_id=#{request_id}")
                Rails.logger.debug("QX API 処理結果詳細: #{poll_result['result'].inspect}")
                return { "result" => poll_result["result"] }
                
              when "error"
                # エラー
                error_message = poll_result["error"] || "処理エラー"
                Rails.logger.error("QX API 処理エラー発生: request_id=#{request_id}, error=#{error_message}")
                return { "error" => error_message }
                
              when "processing"
                # まだ処理中 - 待機して再試行
                Rails.logger.info("QX API 処理中: request_id=#{request_id}, #{polling_interval}秒待機後に再試行")
                sleep(polling_interval)
                retry_count += 1
              end
            else
              # APIエラー
              Rails.logger.error("QX API ポーリング失敗: request_id=#{request_id}, status=#{poll_response.status}")
              Rails.logger.error("QX API エラーレスポンス: #{poll_response.body.inspect}")
              return { "error" => "結果取得エラー: HTTPステータス #{poll_response.status}" }
            end
          end
          
          # タイムアウト
          Rails.logger.error("QX API 処理タイムアウト: request_id=#{request_id}, 最大試行回数(#{max_retries})を超過")
          return { "error" => "処理タイムアウト: 最大待機時間を超過しました" }
        else
          # エラー時
          Rails.logger.error("QX API リクエスト失敗: service=#{service}, status=#{response.status}")
          Rails.logger.error("QX API エラー詳細: #{response.body.inspect}")
          return { "error" => "API呼び出しエラー: HTTPステータス #{response.status}" }
        end
      rescue => e
        Rails.logger.error("QX API 例外発生: service=#{service}, 例外クラス=#{e.class.name}")
        Rails.logger.error("QX API 例外メッセージ: #{e.message}")
        Rails.logger.error("QX API スタックトレース: \n#{e.backtrace.join("\n")}")
        return { "error" => "API呼び出し例外: #{e.message}" }
      end
    end

    # 非同期リクエストを開始する
    def start_async_request(service:, params:, user_id:, callback_class:, callback_method:, polling_interval: nil)
      polling_interval ||= @polling_interval
      Rails.logger.info("QX API 非同期処理開始: service=#{service}, user_id=#{user_id}")
      Rails.logger.debug("QX API 非同期リクエストパラメータ詳細: #{params.inspect}")
      
      begin
        request_body = { "body" => params["body"] }
        Rails.logger.debug("QX API 非同期リクエストボディ詳細: #{request_body.inspect}")
        
        Rails.logger.info("QX API 非同期リクエスト送信: service=#{service}, user_id=#{user_id}")
        response = connection.post("#{BASE_URL}/projects/df/#{service}") do |req|
          req.headers['X-API-Key'] = @api_key
          req.headers['Content-Type'] = 'application/json'
          req.body = request_body.to_json
        end
        
        Rails.logger.info("QX API 非同期レスポンス受信: status=#{response.status}")
        Rails.logger.debug("QX API 非同期レスポンス詳細: #{response.body.inspect}")
        
        if response.status == 200 || response.status == 202
          result = response.body.is_a?(String) ? JSON.parse(response.body) : response.body
          request_id = result["request_id"]
          status = result["status"] || "unknown"
          Rails.logger.info("QX API 非同期リクエストID取得成功: request_id=#{request_id}, status=#{status}")
          
          # ポーリング処理を開始（非同期ジョブではなく直接開始）
          poll_request(
            request_id: request_id,
            user_id: user_id,
            callback_class: callback_class,
            callback_method: callback_method,
            polling_interval: polling_interval
          )
        else
          # エラー時
          Rails.logger.error("QX API 非同期リクエスト失敗: service=#{service}, status=#{response.status}")
          Rails.logger.error("QX API 非同期エラー詳細: #{response.body.inspect}")
          
          # コールバックでエラーを返す
          callback_object = callback_class.constantize
          callback_object.send(callback_method, { "error" => "API呼び出しエラー: HTTPステータス #{response.status}" }, user_id)
        end
      rescue => e
        Rails.logger.error("QX API 非同期処理例外発生: service=#{service}, 例外クラス=#{e.class.name}")
        Rails.logger.error("QX API 非同期例外メッセージ: #{e.message}")
        Rails.logger.error("QX API 非同期スタックトレース: \n#{e.backtrace.join("\n")}")
        
        # コールバックでエラーを返す
        callback_object = callback_class.constantize
        callback_object.send(callback_method, { "error" => "API呼び出し例外: #{e.message}" }, user_id)
      end
    end

    # リクエスト結果をポーリングする
    def poll_request(request_id:, user_id:, callback_class:, callback_method:, retry_count: 0, polling_interval: nil)
      polling_interval ||= @polling_interval
      Rails.logger.info("QX API ポーリング実行: request_id=#{request_id}, 試行回数=#{retry_count}/12")
      
      begin
        # 結果を確認
        response = connection.get("#{BASE_URL}/results/#{request_id}") do |req|
          req.headers['X-API-Key'] = @api_key
        end
        
        Rails.logger.debug("QX API ポーリングレスポンス詳細: status=#{response.status}, body=#{response.body.inspect}")
        
        if response.status == 200
          result = response.body.is_a?(String) ? JSON.parse(response.body) : response.body
          status = result["status"] || "unknown"
          Rails.logger.info("QX API ポーリング結果: request_id=#{request_id}, status=#{status}")
          
          case result["status"]
          when "completed"
            # 処理完了 - コールバックを呼び出す
            Rails.logger.info("QX API 処理完了: request_id=#{request_id}")
            Rails.logger.debug("QX API 処理結果詳細: #{result['result'].inspect}")
            callback_object = callback_class.constantize
            callback_object.send(callback_method, { body: result["result"] }, user_id)
            
          when "processing"
            # まだ処理中 - 設定された間隔後に再試行（最大12回=2分）
            if retry_count < 12
              Rails.logger.info("QX API 処理中: request_id=#{request_id}, #{polling_interval}秒後に再試行 (#{retry_count+1}/12)")
              # 遅延実行（Activeジョブを使わずにスレッドベースで実装）
              Thread.new do
                sleep(polling_interval)
                poll_request(
                  request_id: request_id,
                  user_id: user_id,
                  callback_class: callback_class,
                  callback_method: callback_method,
                  retry_count: retry_count + 1,
                  polling_interval: polling_interval
                )
              end
            else
              # タイムアウト
              Rails.logger.error("QX API 処理タイムアウト: request_id=#{request_id}, 最大試行回数(12)を超過")
              callback_object = callback_class.constantize
              callback_object.send(callback_method, { "error" => "処理タイムアウト: 最大待機時間を超過しました" }, user_id)
            end
            
          when "error"
            # エラー
            error_message = result["error"] || "処理エラー"
            Rails.logger.error("QX API 処理エラー発生: request_id=#{request_id}, error=#{error_message}")
            callback_object = callback_class.constantize
            callback_object.send(callback_method, { "error" => error_message }, user_id)
          end
        else
          # APIエラー
          Rails.logger.error("QX API ポーリング失敗: request_id=#{request_id}, status=#{response.status}")
          Rails.logger.error("QX API エラーレスポンス: #{response.body.inspect}")
          
          # エラーが出ても最大12回までポーリングを続ける
          if retry_count < 12
            Rails.logger.info("QX API エラー発生後も再試行: request_id=#{request_id}, #{polling_interval}秒後に再試行 (#{retry_count+1}/12)")
            Thread.new do
              sleep(polling_interval)
              poll_request(
                request_id: request_id,
                user_id: user_id,
                callback_class: callback_class,
                callback_method: callback_method,
                retry_count: retry_count + 1,
                polling_interval: polling_interval
              )
            end
          else
            # 最大試行回数を超えた場合はエラーを返す
            callback_object = callback_class.constantize
            callback_object.send(callback_method, { "error" => "結果取得エラー: HTTPステータス #{response.status}" }, user_id)
          end
        end
      rescue => e
        Rails.logger.error("QX API ポーリング例外発生: request_id=#{request_id}, 例外クラス=#{e.class.name}")
        Rails.logger.error("QX API ポーリング例外メッセージ: #{e.message}")
        Rails.logger.error("QX API ポーリングスタックトレース: \n#{e.backtrace.join("\n")}")
        
        # 例外発生時も最大12回までポーリングを続ける
        if retry_count < 12
          Rails.logger.info("QX API 例外発生後も再試行: request_id=#{request_id}, #{polling_interval}秒後に再試行 (#{retry_count+1}/12)")
          Thread.new do
            sleep(polling_interval)
            poll_request(
              request_id: request_id,
              user_id: user_id,
              callback_class: callback_class,
              callback_method: callback_method,
              retry_count: retry_count + 1,
              polling_interval: polling_interval
            )
          end
        else
          callback_object = callback_class.constantize
          callback_object.send(callback_method, { "error" => "ポーリング例外: #{e.message}" }, user_id)
        end
      end
    end

    private

    def connection
      @connection ||= Faraday.new do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
        # タイムアウト値を設定
        faraday.options.timeout = 600  # リクエストタイムアウト
        faraday.options.open_timeout = 60  # 接続タイムアウト
      end
    end
  end
end 
