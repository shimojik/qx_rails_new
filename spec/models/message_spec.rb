require 'rails_helper'

RSpec.describe Message do
  describe 'アソシエーション' do
    it { is_expected.to belong_to(:chat_room) }
  end

  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:sender_type) }
    it { is_expected.to validate_inclusion_of(:sender_type).in_array(%w[human ai]) }
  end

  describe 'スコープ' do
    it 'ordered は作成日時の昇順でメッセージを返すこと' do
      chat_room = create(:chat_room)
      old_message = create(:message, chat_room: chat_room, created_at: 2.days.ago)
      new_message = create(:message, chat_room: chat_room, created_at: 1.day.ago)
      expect(chat_room.messages.ordered).to eq([old_message, new_message])
    end
  end

  describe '#sender_type_to_s' do
    it 'sender_typeが"human"の場合は"あなた"を返すこと' do
      message = build(:message, sender_type: 'human')
      expect(message.sender_type_to_s).to eq('あなた')
    end

    it 'sender_typeが"ai"の場合は"AI"を返すこと' do
      message = build(:message, sender_type: 'ai')
      expect(message.sender_type_to_s).to eq('AI')
    end
  end
end
