require 'aws-sdk-lambda'
require 'json'

class LambdaService
  attr_reader :client, :function_name

  # 初期化
  def initialize(function_name: nil, region: nil)
    config = Rails.application.config.lambda_function
    @function_name = function_name || config[:name]
    @client = Aws::Lambda::Client.new(region: region || config[:region])
  end

  # Lambdaを呼び出してレスポンスを取得
  def invoke(chain_name, inputs = {})
    payload = {
      chain_name: chain_name,
      inputs: inputs
    }.to_json

    Rails.logger.info("Lambda 呼び出し開始: function=#{function_name}, chain=#{chain_name}")
    Rails.logger.debug("Lambda リクエストペイロード: #{payload}")

    begin
      # Lambdaを同期的に呼び出す
      response = client.invoke({
        function_name: function_name,
        invocation_type: 'RequestResponse', # 同期呼び出し
        payload: payload
      })

      # レスポンスを処理
      response_payload = JSON.parse(response.payload.read)
      
      if response.function_error
        Rails.logger.error("Lambda error: #{response.function_error}, Payload: #{response_payload}")
        raise "Lambda実行エラー: #{response_payload['errorMessage']}"
      end

      # レスポンスボディをJSONとしてパース
      body = JSON.parse(response_payload['body'])
      
      Rails.logger.info("Lambda 呼び出し成功: function=#{function_name}, chain=#{chain_name}")
      Rails.logger.debug("Lambda レスポンスボディ: #{body}")
      
      # 結果を返す
      return body
    rescue => e
      Rails.logger.error("Lambda 呼び出し例外発生: function=#{function_name}, 例外クラス=#{e.class.name}")
      Rails.logger.error("Lambda 例外メッセージ: #{e.message}")
      Rails.logger.error("Lambda スタックトレース: \n#{e.backtrace.join("\n")}")
      
      return { "error" => "Lambda呼び出し例外: #{e.message}" }
    end
  end
end
