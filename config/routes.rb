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
      get :promotion_form
      post :promote
    end
    
    resources :bookings do
      collection do
        get :discuss
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
      get :confirm
      put :exec_confirm
      post :wall_post
      get :renter_confirm
    end
    resources :messages
  end
  
  resource :account, :controller => :account, :only => [:edit, :update, :show]
  
  namespace "connectors" do
    resource :twitter, :controller => :twitter do
      get :callback
    end
  end
end
