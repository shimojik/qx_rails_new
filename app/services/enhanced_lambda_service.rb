class EnhancedLambdaService < LambdaService
  def invoke(chain_name, inputs = {})
    # 処理開始時間を記録
    start_time = Time.current
    
    begin
      # 親クラスのメソッドを呼び出し
      result = super
      
      # 処理時間をログ記録
      duration = Time.current - start_time
      Rails.logger.info("Lambda invocation successful: chain=#{chain_name}, duration=#{duration.round(2)}s")
      
      return result
    rescue => e
      # 例外の種類に応じた適切なエラーに変換
      case e.message
      when /timeout/i
        raise LambdaErrors::TimeoutError, "Lambda実行がタイムアウトしました: #{e.message}"
      when /validation/i
        raise LambdaErrors::ValidationError, "入力パラメータが不正です: #{e.message}"
      else
        raise LambdaErrors::InvocationError, "Lambda実行中にエラーが発生しました: #{e.message}"
      end
    end
  end
  
  # リトライ実装
  def invoke_with_retry(chain_name, inputs, max_retries: 3, backoff: 2)
    retries = 0
    begin
      invoke(chain_name, inputs)
    rescue Aws::Lambda::Errors::ServiceError => e
      if retries < max_retries
        retries += 1
        sleep(backoff ** retries) # 指数バックオフ
        retry
      else
        raise
      end
    end
  end
  
  # 監視情報を追加した呼び出し
  def monitored_invoke(chain_name, inputs, context = {})
    start_time = Time.current
    result = invoke(chain_name, inputs)
    duration = (Time.current - start_time) * 1000 # ミリ秒単位
    
    # カスタムメトリクスの記録（実際の監視システムに合わせて実装）
    record_metric('lambda.invoke.duration', duration, { chain: chain_name })
    record_metric('lambda.invoke.count', 1, { chain: chain_name, status: 'success' })
    
    result
  rescue => e
    record_metric('lambda.invoke.count', 1, { chain: chain_name, status: 'error' })
    raise
  end
  
  private
  
  # メトリクス記録メソッド（実際の監視システムに合わせて実装）
  def record_metric(name, value, tags = {})
    # ここで実際のメトリクス記録処理を実装
    # 例: StatsD, CloudWatch, Datadog, New Relic などに送信
    Rails.logger.info("METRIC: #{name}=#{value} #{tags.map { |k, v| "#{k}=#{v}" }.join(' ')}")
  end
end
