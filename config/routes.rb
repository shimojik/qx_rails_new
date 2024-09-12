Rails.application.routes.draw do
  devise_for :users
  resources :creations, param: :uid, only: %i[new create show index]
  get "creations/fields", to: "creations#fields"
  root "creations#index"
end
