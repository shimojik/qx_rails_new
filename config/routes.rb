Rails.application.routes.draw do
  devise_for :users
  
  # Chat routes
  resources :chats, only: [:create], param: :uid
  get "chats/:uid", to: "chats#show", as: :chat
  
  resources :creations, param: :uid, only: %i[new create show index]
  get "creations/fields", to: "creations#fields"
  root "creations#index"
end
