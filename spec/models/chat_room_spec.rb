require 'rails_helper'

RSpec.describe ChatRoom do
  describe 'アソシエーション' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
  end

  describe 'バリデーション' do
    
    describe 'uid uniqueness' do
      let(:user) { create(:user) }
      
      it 'uidは一意であること' do
        chat_room1 = create(:chat_room, user: user)
        uid = chat_room1.uid
        
        chat_room2 = build(:chat_room, user: user, uid: uid)
        
        expect(chat_room2).not_to be_valid
        expect(chat_room2.errors[:uid]).to be_present
      end
    end
  end

  describe 'UidModule' do
    let(:user) { create(:user) }
    
    it 'ビルド時にUIDを明示的に設定できること' do
      chat_room = build(:chat_room, user: user, uid: 'custom-uid')
      expect(chat_room.uid).to eq('custom-uid')
    end

    it '作成時にUIDが自動生成されること' do
      chat_room = create(:chat_room, user: user)
      expect(chat_room.uid).not_to be_nil
      expect(chat_room.uid).to include(chat_room.id.to_s)
    end
  end

  describe '#to_param' do
    it 'UIDを返すこと' do
      chat_room = create(:chat_room)
      expect(chat_room.to_param).to eq(chat_room.uid)
    end
  end
end
