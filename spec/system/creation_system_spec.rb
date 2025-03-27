require 'rails_helper'

RSpec.describe 'コンテンツ生成システム', type: :system do
  let(:user) { create(:user) }
  
  before do
    driven_by(:rack_test)
    sign_in user
  end
  
  describe 'コンテンツ一覧表示' do
    let!(:creation) { create(:creation, user: user, assistant_service: 'content_generator', content_body: 'テストコンテンツ') }
    
    it '自分のコンテンツ一覧を表示できること' do
      visit creations_path
      
      expect(page).to have_content('テストコンテンツ')
    end
  end
  
  describe 'コンテンツ詳細表示' do
    let!(:creation) { create(:creation, user: user, assistant_service: 'content_generator', content_body: 'テスト詳細コンテンツ') }
    
    it 'コンテンツの詳細を表示できること' do
      visit creation_path(creation.uid)
      
      expect(page).to have_content('テスト詳細コンテンツ')
    end
  end
  
  describe 'コンテンツ作成' do
    before do
      allow_any_instance_of(CreationsController).to receive(:get_services).and_return(['content_generator'])
      allow_any_instance_of(CreationsController).to receive(:get_form_fields).and_return([
        { name: 'prompt', label: 'プロンプト', type: 'text_area' }
      ])
      allow(CreateCreationJob).to receive(:perform_async)
    end
    
    it '新しいコンテンツを作成できること' do
      visit new_creation_path
      
      fill_in 'プロンプト', with: 'テストプロンプト'
      select 'content_generator', from: 'assistant_service'
      
      expect {
        click_button '作成'
      }.to change(Creation, :count).by(1)
    end
  end
end
