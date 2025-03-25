class Message < ApplicationRecord
  belongs_to :chat_room
  
  validates :content, presence: true
  validates :sender_type, presence: true, inclusion: { in: %w[human ai] }
  
  scope :ordered, -> { order(created_at: :asc) }
  def sender_type_to_s
    case sender_type
    when 'human'
      'あなた'
    when 'ai'
      'AI'
    end
  end
end
