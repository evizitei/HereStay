Micasasucasa::Application.routes.draw do
  root :to => "rental_units#index"
  resources :photos do
    collection do
      post :ajaxupload
      post :ajaxupload_remote
    end      
  end
  
  resources :delayed_jobs
  resources :unit_photos

  match "/chat_poll"=>"messages#poll_chat"
  match "/chat_post"=>"messages#post_chat"
  match "/chat_check"=>"messages#check_messages"


  resources :rental_units do
    collection do
      get :manage
      get :search
      get :owned_by
      post :save
      post :import
      post :preview
      post :load_data_from_vrbo
      post :vrbo_listings
    end
    
    member do
      put :load_from_vrbo
      get :share
      post :store_last_post
      get :availabilities
      put :preview_update
      post :store_last_comment
      put :load_data_from_vrbo
      get :promote
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
        post :generate
      end
    end
    resources :reservations do
      collection do
        post :import
      end
    end
    resources :inquiries, :only => [:index, :new] do
      collection do
        get :messages
      end
      member do
        post :terminate
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
    get :my_history
    get :my_place
    get :my_rewards
  end
  
  resource :subscription do
    get :change_plan
  end
  
  resources :relations, :only => [:show]
  namespace "connectors" do
    resource :twitter, :controller => :twitter do
      get :callback
    end
  end
  
  resources :inquiries, :only => [:index] do
    collection do
      get :messages
    end
    member do
      post :terminate
    end
  end
  
  namespace "admin" do
    root :to => "funds#index"
    resources :funds
  end
  
  namespace "auction" do
    root :to => "lots#index"
    resources :lots, :path => 'auctions' do
      member do
        put :finish
      end
      collection do
        get :search
      end
      resources :bids do
        member do
          put :win
          get :win
        end
      end
    end
  end
  
  resources :deals do
    member do
      put :make
    end
    collection do
      get :search
    end
  end
  
  namespace "renter" do
    resources :bookings, :only => [:index, :confirm] do
      member do
        get :confirm
      end
    end
  end
end
