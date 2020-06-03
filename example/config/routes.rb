Rails.application.routes.draw do
  resources :posts
  resources :people do
    get :swagger, on: :collection
  end

  mount SoberSwag::Server.new, at: '/swagger'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
