require 'rails_helper'

RSpec.describe 'チャットシステム', type: :system do
  let(:user) { create(:user) }
  let(:chat_room) { create(:chat_room, user: user) }
  
  before do
    driven_by(:rack_test)
    sign_in user
  end
  
  describe 'チャットルーム作成' do
    it '新しいチャットルームを作成できること' do
      visit root_path
      click_link 'チャットを始める'
      
      expect(page).to have_content('新しいチャット')
      expect(ChatRoom.count).to eq(1)
    end
  end
  
  describe 'メッセージ送信' do
    before do
      allow_any_instance_of(EnhancedLambdaService).to receive(:invoke_with_retry).and_return({
        "result" => "AIからの返信です"
      })
    end
    
    it 'メッセージを送信できること' do
      visit chat_path(chat_room.uid)
      
      fill_in 'message_content', with: 'こんにちは'
      click_button '送信'
      
      expect(page).to have_content('こんにちは')
      expect(Message.where(sender_type: 'human').count).to eq(1)
    end
  end
end
