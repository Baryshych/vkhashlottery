Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'lottery#index'
  post '/find' => 'lottery#find'
  post '/reroll' => 'lottery#reroll'
end
