require 'rails_helper'

RSpec.describe CreateCreationJob do
  describe '#perform' do
    let(:user) { create(:user) }
    let(:creation) { create(:creation, user: user, assistant_service: 'content_generator') }
    let(:ai_service) { class_double("Assistants::ContentGenerator") }
    
    before do
      allow(Rails.logger).to receive(:info)
      allow(Assistants::ContentGenerator).to receive(:generate).and_return({
        body: 'テスト生成コンテンツ'
      })
      stub_const("Assistants::ContentGenerator", ai_service)
    end
    
    it 'AIサービスを呼び出し、結果を保存すること' do
      expect {
        CreateCreationJob.new.perform(creation.id, { 'ai_form_data' => { body: 'テスト入力' } })
      }.to change { creation.reload.content_body }.from(nil).to('テスト生成コンテンツ')
    end
    
    context 'when 評価サービスが指定されている場合' do
      let(:creation) { create(:creation, user: user, assistant_service: 'content_generator', evaluation_service: 'summary_generator_evaluator') }
      let(:evaluation_service) { class_double("Evaluations::SummaryGeneratorEvaluator") }
      
      before do
        allow(Evaluations::SummaryGeneratorEvaluator).to receive(:evaluate).and_return({
          process: 'テスト評価プロセス',
          score: 85,
          comment: 'テスト評価コメント'
        })
        stub_const("Evaluations::SummaryGeneratorEvaluator", evaluation_service)
      end
      
      it '評価サービスを呼び出し、結果を保存すること' do
        expect {
          CreateCreationJob.new.perform(creation.id, { 
            'ai_form_data' => { body: 'テスト入力' },
            'evaluation_form_data' => { criteria: 'テスト基準' }
          })
        }.to change { creation.reload.evaluation_score }.from(nil).to(85)
      end
      
      it '評価コメントを保存すること' do
        CreateCreationJob.new.perform(creation.id, { 
          'ai_form_data' => { body: 'テスト入力' },
          'evaluation_form_data' => { criteria: 'テスト基準' }
        })
        expect(creation.reload.evaluation_comment).to eq('テスト評価コメント')
      end
      
      it '評価プロセスを保存すること' do
        CreateCreationJob.new.perform(creation.id, { 
          'ai_form_data' => { body: 'テスト入力' },
          'evaluation_form_data' => { criteria: 'テスト基準' }
        })
        expect(creation.reload.evaluation_process).to eq('テスト評価プロセス')
      end
    end
  end
end
