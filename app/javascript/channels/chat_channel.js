import consumer from "./consumer"
import { marked } from 'marked'

document.addEventListener('turbo:load', function() {
  const chatContainer = document.getElementById('chat-container');
  
  if (chatContainer) {
    const chatRoomUid = chatContainer.dataset.chatRoomUid;
    
    // 送信者タイプを日本語表示に変換する関数
    function senderTypeToString(senderType) {
      switch(senderType) {
        case 'human':
          return 'あなた';
        case 'ai':
          return 'AI';
        case 'system':
          return 'システム';
        default:
          return senderType;
      }
    }
    
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
        
        // 送信者表示を追加
        const messageSender = document.createElement('div');
        messageSender.classList.add('message-sender');
        messageSender.textContent = senderTypeToString(data.sender_type);
        messageContainer.appendChild(messageSender);
        
        // マークダウンをHTMLとしてレンダリング
        const messageContent = document.createElement('div');
        messageContent.classList.add('message-content');
        messageContent.innerHTML = marked.parse(data.message);
        
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
