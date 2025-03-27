FactoryBot.define do
  factory :message do
    association :chat_room
    content { 'テストメッセージ' }
    sender_type { 'human' }
  end
end
