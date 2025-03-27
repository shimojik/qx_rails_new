require 'rails_helper'

RSpec.describe HomeController do
  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
    
    it 'AIサービスを割り当てること' do
      allow(controller).to receive(:get_services).and_return(['test_service'])
      get :index
      expect(assigns(:ai_services)).to eq(['test_service'])
    end
    
    it '選択されたAIサービスを割り当てること' do
      allow(controller).to receive(:current_ai_service).and_return('test_service')
      get :index
      expect(assigns(:selected_ai_service)).to eq('test_service')
    end
    
    it 'indexテンプレートをレンダリングすること' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
