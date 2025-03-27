require 'rails_helper'

RSpec.describe UidModule do
  let(:chat_room) { create(:chat_room) }

  describe 'after_createコールバック' do
    it '作成後にUIDが存在すること' do
      expect(chat_room.uid).not_to be_nil
    end

    it '作成後のUIDにIDが含まれること' do
      expect(chat_room.uid).to include(chat_room.id.to_s)
    end
  end

  describe '#to_param' do
    it 'UIDを返すこと' do
      expect(chat_room.to_param).to eq(chat_room.uid)
    end
  end
end
