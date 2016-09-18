Rails.application.routes.draw do

  get  'instructions/index'
  post 'instructions/execute'
  root 'instructions#index'

  resources :instructions do
    get "delete"
  end

end
