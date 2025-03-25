class ChatChannel < ApplicationCable::Channel
  def subscribed
    chat_room = ChatRoom.find_by(uid: params[:uid])
    # Only allow the chat room owner to subscribe to this channel
    if chat_room && chat_room.user == current_user
      stream_for chat_room
    else
      # Reject the subscription if not the owner
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    chat_room = ChatRoom.find_by(uid: params[:uid])
    # Verify ownership again for every message
    return unless chat_room && chat_room.user == current_user
    
    # Get the user message
    user_message = data['message']
    
    # Save the human message
    human_message = chat_room.messages.create!(
      content: user_message,
      sender_type: 'human'
    )
    
    # Broadcast the human message
    ChatChannel.broadcast_to(
      chat_room,
      { message: human_message.content, sender_type: human_message.sender_type, id: human_message.id }
    )
    
    # Use the enhanced Lambda service with retry and monitoring capabilities
    begin
      lambda_service = EnhancedLambdaService.new
      chat_history = chat_room.messages.order(created_at: :asc).last(15).map { |m| "#{m.sender_type}: #{m.content}" }.join("\n")
      params = {
        "chat_history" => chat_history,
        "new_message" => user_message
      }
      response = lambda_service.invoke_with_retry('chat_response', params, max_retries: 2)
      ai_content = if response["error"]
        "エラーが起きました(#{response["error"]})"
      else
        response["result"] || "返信がありませんでした"
      end
      
      # Create and save the AI response
      ai_message = chat_room.messages.create!(
        content: ai_content,
        sender_type: 'ai'
      )
      
      # Broadcast the AI response
      ChatChannel.broadcast_to(
        chat_room,
        { message: ai_message.content, sender_type: ai_message.sender_type, id: ai_message.id }
      )
    rescue LambdaErrors::TimeoutError => e
      # Handle timeout specifically
      error_message = "応答生成がタイムアウトしました。しばらく経ってからもう一度お試しください。"
      Rails.logger.error("Chat Lambda timeout: #{e.message}")
      
      send_error_message(chat_room, error_message)
    rescue LambdaErrors::ValidationError => e
      # Handle validation errors
      error_message = "入力内容に問題があります。別の質問をお試しください。"
      Rails.logger.error("Chat Lambda validation error: #{e.message}")
      
      send_error_message(chat_room, error_message)
    rescue => e
      # Handle other errors
      error_message = "エラーが発生しました。しばらく経ってからもう一度お試しください。"
      Rails.logger.error("Chat Lambda general error: #{e.class.name} - #{e.message}")
      
      send_error_message(chat_room, error_message)
    end
  end
  
  private
  
  # Helper method to send error messages to the chat
  def send_error_message(chat_room, error_content)
    error_message = chat_room.messages.create!(
      content: error_content,
      sender_type: 'system'
    )
    
    ChatChannel.broadcast_to(
      chat_room,
      { message: error_message.content, sender_type: error_message.sender_type, id: error_message.id }
    )
  end
end
