import consumer from "./consumer"

document.addEventListener('turbo:load', function() {
  const chatContainer = document.getElementById('chat-container');
  
  if (chatContainer) {
    const chatRoomUid = chatContainer.dataset.chatRoomUid;
    
    consumer.subscriptions.create({ channel: "ChatChannel", uid: chatRoomUid }, {
      connected() {
        console.log("Connected to ChatChannel");
      },
      
      disconnected() {
        console.log("Disconnected from ChatChannel");
      },
      
      received(data) {
        // Create message element
        const messageContainer = document.createElement('div');
        messageContainer.classList.add('message', data.sender_type);
        
        const messageContent = document.createElement('div');
        messageContent.classList.add('message-content');
        messageContent.textContent = data.message;
        
        messageContainer.appendChild(messageContent);
        
        // Add to chat history
        const chatHistory = document.querySelector('.chat-history');
        chatHistory.appendChild(messageContainer);
        
        // Scroll to bottom
        chatHistory.scrollTop = chatHistory.scrollHeight;
        
        // Clear the input field if this is a human message
        if (data.sender_type === 'human') {
          document.getElementById('message-input').value = '';
        }
      }
    });
    
    // Form submission handler
    const messageForm = document.getElementById('message-form');
    if (messageForm) {
      messageForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const input = document.getElementById('message-input');
        const message = input.value.trim();
        
        if (message.length > 0) {
          // Send to ActionCable
          consumer.subscriptions.subscriptions[0].send({ message: message });
          
          // Don't clear input here, it will be cleared when the message is received back
        }
      });
    }
  }
});
