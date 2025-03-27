require 'rails_helper'

RSpec.describe EnhancedLambdaService, type: :service do
  let(:service) { described_class.new }
  
  before do
    allow_any_instance_of(LambdaService).to receive(:invoke).and_return({ 'result' => 'success' })
  end

  describe '#invoke' do
    it 'スーパークラスのメソッドを呼び出し、結果を返すこと' do
      result = service.invoke('test_chain', { key: 'value' })
      expect(result).to eq({ 'result' => 'success' })
    end

    context 'when エラーが発生する場合' do
      before do
        allow_any_instance_of(LambdaService).to receive(:invoke).and_raise(StandardError.new('一般的なエラー'))
      end

      it '適切なエラーを発生させること' do
        expect do
          service.invoke('test_chain', {})
        end.to raise_error(LambdaErrors::InvocationError)
      end
    end

    context 'when タイムアウトエラーが発生する場合' do
      before do
        allow_any_instance_of(LambdaService).to receive(:invoke).and_raise(StandardError.new('timeout error'))
      end

      it 'TimeoutErrorを発生させること' do
        expect do
          service.invoke('test_chain', {})
        end.to raise_error(LambdaErrors::TimeoutError)
      end
    end

    context 'when バリデーションエラーが発生する場合' do
      before do
        allow_any_instance_of(LambdaService).to receive(:invoke).and_raise(StandardError.new('validation error'))
      end

      it 'ValidationErrorを発生させること' do
        expect do
          service.invoke('test_chain', {})
        end.to raise_error(LambdaErrors::ValidationError)
      end
    end
  end

  describe '#invoke_with_retry' do
    before do
      allow(service).to receive(:invoke).and_return({ 'result' => 'success' })
    end

    it '正しいパラメータでinvokeを呼び出すこと' do
      service.invoke_with_retry('test_chain', { key: 'value' })
      expect(service).to have_received(:invoke).with('test_chain', { key: 'value' })
    end

    context 'when invokeがエラーを発生させる場合' do
      before do
        call_count = 0
        allow(service).to receive(:invoke) do
          call_count += 1
          raise Aws::Lambda::Errors::ServiceError.new(nil, 'サービスエラー') if call_count == 1

          { 'result' => 'success' }
        end
        allow(service).to receive(:sleep)
      end

      it '呼び出しをリトライすること' do
        result = service.invoke_with_retry('test_chain', {}, max_retries: 2)
        expect(result).to eq({ 'result' => 'success' })
      end

      it 'invokeが複数回呼び出されること' do
        service.invoke_with_retry('test_chain', {}, max_retries: 2)
        expect(service).to have_received(:invoke).twice
      end
    end
  end

  describe '#monitored_invoke' do
    before do
      allow(service).to receive(:invoke).and_return({ 'result' => 'success' })
      allow(service).to receive(:record_metric)
    end

    it '正しいパラメータでinvokeを呼び出すこと' do
      service.monitored_invoke('test_chain', { key: 'value' })
      expect(service).to have_received(:invoke).with('test_chain', { key: 'value' })
    end

    it '成功時のメトリクスを記録すること' do
      service.monitored_invoke('test_chain', {})
      expect(service).to have_received(:record_metric)
        .with('lambda.invoke.duration', anything, { chain: 'test_chain' })
    end

    it '成功カウントメトリクスを記録すること' do
      service.monitored_invoke('test_chain', {})
      expect(service).to have_received(:record_metric)
        .with('lambda.invoke.count', 1, { chain: 'test_chain', status: 'success' })
    end

    context 'when エラーが発生する場合' do
      before do
        allow(service).to receive(:invoke).and_raise(StandardError)
      end

      let(:error_metric_params) do
        { chain: 'test_chain', status: 'error' }
      end

      it 'エラーが発生すること' do
        expect do
          service.monitored_invoke('test_chain', {})
        end.to raise_error(StandardError)
      end

      it 'エラーメトリクスを記録すること' do
        allow(service).to receive(:monitored_invoke).and_call_original
        allow(service).to receive(:invoke).and_raise(StandardError)

        service.send(:record_metric, 'lambda.invoke.count', 1, error_metric_params)

        expect(service).to have_received(:record_metric)
          .with('lambda.invoke.count', 1, error_metric_params)
      end
    end
  end
end
