class ChatRoom < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy
  
  validates :uid, presence: true, uniqueness: true
  
  before_validation :generate_uid, on: :create
  
  private
  
  def generate_uid
    self.uid ||= SecureRandom.uuid
  end
end
