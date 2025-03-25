class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat_room, only: [:show]
  before_action :check_chat_owner, only: [:show]
  
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
  
  # def generate_ai_response(chat_room = nil, message = nil)
  #   chat_history = chat_room.messages.order(created_at: :asc).last(15).map { |m| "#{m.sender_type}: #{m.content}" }.join("\n")
  #   lambda_service = EnhancedLambdaService.new
  #   params = {
  #     "chat_history" => chat_history,
  #     "new_message" => message
  #   }
    
  #   begin
  #     response = lambda_service.invoke_with_retry('chat_response', params, max_retries: 2)
  #     if response["error"]
  #       "エラーが起きました(#{response["error"]})"
  #     else
  #       response["response"] || response["content"] || response["answer"] || "返信がありませんでした"
  #     end
  #   rescue => e
  #     Rails.logger.error("Lambda呼び出しエラー: #{e.message}")
  #     "エラーが起きました: #{e.message}"
  #   end
  # end
  
  private
  
  def set_chat_room
    @chat_room = ChatRoom.find_by!(uid: params[:uid])
  end
  
  def check_chat_owner
    unless @chat_room.user == current_user
      flash[:alert] = "このチャットへのアクセス権限がありません。"
      redirect_to root_path
    end
  end
end
