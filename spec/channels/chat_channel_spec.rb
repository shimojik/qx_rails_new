require 'rails_helper'

RSpec.describe ChatChannel do
  let(:user) { create(:user) }
  let(:chat_room) { create(:chat_room, user: user) }
  
  before do
    stub_connection current_user: user
  end
  
  describe '#subscribed' do
    it 'チャットルームにストリームをサブスクライブすること' do
      subscribe(uid: chat_room.uid)
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(chat_room)
    end
    
    context 'when ユーザーがチャットルームの所有者でない場合' do
      let(:other_user) { create(:user) }
      let(:other_chat_room) { create(:chat_room, user: other_user) }
      
      it 'サブスクリプションを拒否すること' do
        subscribe(uid: other_chat_room.uid)
        expect(subscription).to be_rejected
      end
    end
  end
  
  describe '#receive' do
    before do
      subscribe(uid: chat_room.uid)
      allow_any_instance_of(EnhancedLambdaService).to receive(:invoke_with_retry).and_return({
        "result" => "AIからの返信です"
      })
    end
    
    it '人間のメッセージを作成すること' do
      expect {
        perform :receive, { "message" => "こんにちは" }
      }.to change { chat_room.messages.where(sender_type: 'human').count }.by(1)
    end
    
    it 'AIのメッセージを作成すること' do
      expect {
        perform :receive, { "message" => "こんにちは" }
      }.to change { chat_room.messages.where(sender_type: 'ai').count }.by(1)
    end
    
    it '人間のメッセージをブロードキャストすること' do
      expect {
        perform :receive, { "message" => "こんにちは" }
      }.to have_broadcasted_to(chat_room).exactly(:twice)
    end
    
    context 'when Lambda呼び出しでエラーが発生する場合' do
      before do
        allow_any_instance_of(EnhancedLambdaService).to receive(:invoke_with_retry).and_raise(LambdaErrors::TimeoutError.new("タイムアウト"))
      end
      
      it 'エラーメッセージを送信すること' do
        expect {
          perform :receive, { "message" => "こんにちは" }
        }.to change { chat_room.messages.where(sender_type: 'system').count }.by(1)
      end
    end
  end
end
