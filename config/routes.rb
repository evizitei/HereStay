Micasasucasa::Application.routes.draw do |map|
  resources :photos
  resources :delayed_jobs
  resources :unit_photos

  resources :rental_units do
    member do
      get :gallery
      get :map
      get :watch_video
    end
    
    resources :photos
  end

  match "/"=>"main#home"
  match "/canvas"=>"canvas#index"
  match "/canvas/"=>"canvas#index"
  
  
  match "/video_uploaded"=>"my_rental_units#video_uploaded"
  
  match "/debug/geocode"=>"debug#geocode"

  resources :my_rental_units do
    collection do
      get :manage
      post :save
    end
    
    member do
      get :photos_for
      get :upload_video_for
    end
    
    resources :bookings do
    end
  end
  
  resources :accounts do
    member do
      get :edit
      get :save
    end
  end
  
  # scope "canvas" do 
  #   match "/search"=>"canvas#search"
  #   match "/my_rental_units"=>"my_rental_units#index"
  #   match "/my_rental_units/show"=>"my_rental_units#show"
  #   match "/manage_my_rental_units"=>"my_rental_units#manage"
  #   match "/my_rental_units/new"=>"my_rental_units#new"
  #   match "/my_rental_units/edit"=>"my_rental_units#edit"
  #   match "my_rental_listings/save"=>"my_rental_units#save"
  #   match "/my_rental_units/share"=>"my_rental_units#share"
  #   match "/my_rental_unit_photos"=>"my_rental_units#photos"
  #   match "/my_rental_units/delete_photo"=>"my_rental_units#delete_photo"
  #   match "/my_rental_listings/new_photo"=>"my_rental_units#new_photo"
  #   match "/my_rental_listings/owned_by"=>"my_rental_units#owned_by"
  #   match "/my_rental_unit_video"=>"my_rental_units#upload_video"
  #   match "/my_rental_units/delete"=>"my_rental_units#delete"
  #   match "/my_rental_units/bookings"=>"bookings#index"
  #   match "/my_rental_units/new_booking"=>"bookings#new"
  #   match "/my_rental_units/create_booking"=>"bookings#create"
  #   match "/bookings/discuss"=>"bookings#discuss"
  #   match "/booking/messages/create"=>"bookings#create_message"
  #   match "/booking/confirm"=>"bookings#confirm"
  #   match "/booking/details"=>"bookings#details"
  #   match "/bookings/wall_post"=>"bookings#wall_post"
  #   match "/bookings/exec_confirm"=>"bookings#exec_confirm"
  #   match "/account/edit"=>"account#edit"
  #   match "/account/save"=>"account#save"
  # end

end
