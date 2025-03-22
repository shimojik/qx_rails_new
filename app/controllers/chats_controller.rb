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
  def generate_ai_response(chat_room = nil, message = nil)
    client = Client::QxAiApiClient.new

    # チャット履歴を取得（実際の実装に合わせて調整が必要）
    chat_history = chat_room.messages.order(created_at: :asc).last(15).map { |m| "#{m.sender_type}: #{m.content}" }.join("\n")

    # QX AI APIにリクエストを送信
    params = {
      "body" => {
        "chat_history" => chat_history,
        "new_message" => message
      }
    }
    
    response = client.run_request(
      service: 'blog/article_generator',
      params: params
    )

    if response["error"]
      # エラーの場合はエラーメッセージを返す
      "エラーが起きました(#{response["error"]})"
    else
      # 成功の場合はレスポンスの本文を返す
      response["result"]["body"] || "返信がありませんでした"
    end
  end
  
  private
  
  def set_chat_room
    @chat_room = ChatRoom.find_by!(uid: params[:uid])
  end
end
