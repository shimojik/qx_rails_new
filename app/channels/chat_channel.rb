class ChatChannel < ApplicationCable::Channel
  def subscribed
    chat_room = ChatRoom.find_by(uid: params[:uid])
    stream_for chat_room if chat_room
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    chat_room = ChatRoom.find_by(uid: params[:uid])
    return unless chat_room
    
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
    
    # Get AI response from controller, passing the user's message
    controller = ChatsController.new
    ai_response = controller.generate_ai_response(chat_room,user_message)
    
    # Create and save the AI response
    ai_message = chat_room.messages.create!(
      content: ai_response,
      sender_type: 'ai'
    )
    
    # Broadcast the AI response
    ChatChannel.broadcast_to(
      chat_room,
      { message: ai_message.content, sender_type: ai_message.sender_type, id: ai_message.id }
    )
  end
end
