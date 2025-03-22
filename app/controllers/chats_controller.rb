class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat_room, only: [:show]
  
  def show
    @messages = @chat_room.messages.ordered
    @message = Message.new
  end
  
  def create
    @chat_room = current_user.chat_rooms.build
    
    if @chat_room.save
      redirect_to chat_path(@chat_room.uid)
    else
      redirect_to root_path, alert: "Failed to create chat room."
    end
  end
  
  # AIメッセージの応答を生成するメソッド
  def generate_ai_response
    responses = ["やあ", "いいね", "OK"]
    responses.sample
  end
  
  private
  
  def set_chat_room
    @chat_room = ChatRoom.find_by!(uid: params[:uid])
  end
end
