EndeudaMe::Application.routes.draw do

  devise_for :users, 
             :controllers => {
               :omniauth_callbacks => 'users/omniauth_callbacks'
             }

  # Root when logged
  authenticated :user do
      root to: "application#index", as: "authenticated_root"
  end

  # Root when not logged
  root "static#wellcome_page"

  namespace :api, :defaults => { :format => :json } do
    resources :users
    resources :movements
    resources :groups
    resources :contacts
    post "/contacts/check_registered", to: "contacts#check_registered", as: :contacts_check_registered
  end
  
end