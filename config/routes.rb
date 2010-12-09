Micasasucasa::Application.routes.draw do
  root :to => "canvas#index"
  resources :photos
  resources :delayed_jobs
  resources :unit_photos

  match "/chat_poll"=>"messages#poll_chat"
  match "/chat_post"=>"messages#post_chat"
  match "/chat_check"=>"messages#check_messages"

  match "/canvas"=>"canvas#index"
  match "/canvas/"=>"canvas#index"
  
  
  resources :rental_units do
    collection do
      get :manage
      post :save
      get :owned_by
      post :import
    end
    
    member do
      put :load_from_vrbo
      get :share
      post :store_last_post
      get :availabilities
    end
    
    resources :bookings do
      collection do
        get :discuss
      end
      member do
        get :reserve
        put :exec_reserve
        post :cancel
      end
    end
    resources :photos
    
    resource :video, :only => [:show, :save, :destroy] do
      member do
        get :save
      end
    end
    resources :reservations do
      collection do
        post :import
      end
    end
  end
  
  resources :bookings do
    member do
      get :discuss
      get :mobile_discuss
      get :reserve
      put :exec_reserve
      post :wall_post
      get :confirm
      post :cancel
    end
    resources :messages
    match "confirmation"=>"confirmations#index"
  end
  
  namespace :mobile do
    resources :bookings do
      member do
        get :discuss
      end
      resources :messages
    end
  end
  
  resource :account, :controller => :account, :only => [:edit, :update, :show] do
    get :my_stays
    get :my_place
    get :my_rewards
  end
  resource :subscription, :only => [:edit, :update, :destroy]
  
  resources :relations, :only => [:show]
  namespace "connectors" do
    resource :twitter, :controller => :twitter do
      get :callback
    end
  end
  
  namespace "admin" do
    root :to => "funds#index"
    resources :funds
  end
end
