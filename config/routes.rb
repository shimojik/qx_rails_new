Rails.application.routes.draw do
  devise_for :users
  resources :creations, param: :uid, only: %i[new create show index]
  get "creations/fields", to: "creations#fields"
  root "creations#index"
  
  # SidekiqのWebインターフェースをマウント
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
