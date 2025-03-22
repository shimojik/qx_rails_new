class Message < ApplicationRecord
  belongs_to :chat_room
  
  validates :content, presence: true
  validates :sender_type, presence: true, inclusion: { in: %w[human ai] }
  
  scope :ordered, -> { order(created_at: :asc) }
end
