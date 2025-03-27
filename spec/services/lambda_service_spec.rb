require 'rails_helper'

RSpec.describe LambdaService, type: :service do
  let(:service) { described_class.new }
  let(:response_body) { { 'body' => { 'result' => 'success' }.to_json } }
  let(:lambda_response) { create_response(response_body) }
  let(:client) { instance_double(Aws::Lambda::Client) }

  def create_response(body, error = nil)
    payload = double('payload')
    allow(payload).to receive(:read).and_return(body.to_json)
    
    instance_double(Aws::Lambda::Types::InvocationResponse, 
                   payload: payload, 
                   function_error: error)
  end

  before do
    allow(Aws::Lambda::Client).to receive(:new).and_return(client)
    allow(client).to receive(:invoke).and_return(lambda_response)
    allow(Rails.application.config).to receive(:lambda_function).and_return({
                                                                              name: 'test_function',
                                                                              region: 'ap-northeast-1'
                                                                            })
  end

  describe '#initialize' do
    it '関数名を設定すること' do
      expect(service.function_name).to eq('test_function')
    end

    it 'クライアントを設定すること' do
      expect(service.client).to eq(client)
    end

    it '関数名をオーバーライドできること' do
      custom_service = described_class.new(function_name: 'custom_function', region: 'us-east-1')
      expect(custom_service.function_name).to eq('custom_function')
    end

    it 'リージョンをオーバーライドできること' do
      described_class.new(function_name: 'custom_function', region: 'us-east-1')
      expect(Aws::Lambda::Client).to have_received(:new).with(region: 'us-east-1')
    end
  end

  describe '#invoke' do
    before do
      allow(client).to receive(:invoke).and_return(lambda_response)
    end

    let(:expected_params) do
      {
        function_name: 'test_function',
        invocation_type: 'RequestResponse',
        payload: { chain_name: 'test_chain', inputs: { key: 'value' } }.to_json
      }
    end

    it '正しいパラメータでLambda関数を呼び出すこと' do
      service.invoke('test_chain', { key: 'value' })
      expect(client).to have_received(:invoke).with(expected_params)
    end

    it 'パースされたレスポンスボディを返すこと' do
      result = service.invoke('test_chain', {})
      expect(result).to eq({ 'result' => 'success' })
    end

    context 'when 関数がエラーを返す場合' do
      it 'エラーメッセージを含むハッシュを返すこと' do
        error_payload = StringIO.new({ 'errorMessage' => 'テストエラー' }.to_json)
        
        error_response = instance_double(
          Aws::Lambda::Types::InvocationResponse,
          payload: error_payload,
          function_error: 'Handled'
        )
        
        allow(service).to receive(:raise).and_raise(StandardError.new('テストエラー'))
        allow(client).to receive(:invoke).and_return(error_response)
        
        result = service.invoke('test_chain', {})
        expect(result).to include('error')
      end
    end

    context 'when 例外が発生する場合' do
      before do
        allow(client).to receive(:invoke).and_raise(StandardError.new('テスト例外'))
      end

      it 'エラーをログに記録すること' do
        result = service.invoke('test_chain', {})
        expect(result).to include('error')
      end

      it 'エラーハッシュを返すこと' do
        result = service.invoke('test_chain', {})
        expect(result['error']).to include('テスト例外')
      end
    end
  end
end
