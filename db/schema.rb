# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110113120825) do

  create_table "bids", :force => true do |t|
    t.integer  "user_id"
    t.integer  "cents"
    t.integer  "lot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "winning",    :default => false, :null => false
  end

  create_table "booking_messages", :force => true do |t|
    t.string   "user_fb_id"
    t.integer  "booking_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recipient_id"
  end

  create_table "bookings", :force => true do |t|
    t.integer  "rental_unit_id"
    t.string   "owner_fb_id"
    t.string   "renter_name"
    t.string   "renter_fb_id"
    t.date     "start_date"
    t.date     "stop_date"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.float    "amount"
    t.datetime "confirmed_by_renter_at"
  end

  add_index "bookings", ["rental_unit_id"], :name => "index_bookings_on_rental_unit_id"

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.string   "fb_user_id"
    t.integer  "rental_unit_id"
    t.text     "text"
    t.string   "fb_id"
    t.integer  "likes"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deals", :force => true do |t|
    t.date     "start_on"
    t.date     "end_on"
    t.integer  "cents",          :default => 0
    t.integer  "user_id"
    t.integer  "rental_unit_id"
    t.integer  "percent"
    t.string   "status",         :default => "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discounts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "booking_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funds", :force => true do |t|
    t.string   "type"
    t.string   "state"
    t.integer  "user_id"
    t.integer  "document_id"
    t.string   "document_type"
    t.integer  "cents",          :default => 0, :null => false
    t.string   "transaction_id"
    t.text     "description"
    t.datetime "processed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lots", :force => true do |t|
    t.string   "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "min_bid_cents"
    t.integer  "min_nights"
    t.text     "terms"
    t.boolean  "socially_connected"
    t.boolean  "stayed_before"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "arrive_on"
    t.date     "depart_on"
    t.boolean  "accept_bids_under_minimum", :default => false, :null => false
    t.text     "cancel_bid_policy"
    t.boolean  "completed",                 :default => false, :null => false
  end

  create_table "photos", :force => true do |t|
    t.integer  "rental_unit_id"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_remote_url"
    t.boolean  "primary",              :default => false
  end

  create_table "rental_units", :force => true do |t|
    t.string   "fb_user_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "pricing"
    t.integer  "percent_discount"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "lat"
    t.string   "long"
    t.boolean  "geocoding_success"
    t.string   "geocoded_address"
    t.datetime "geocoded_at"
    t.string   "video_id"
    t.string   "video_code"
    t.string   "video_status"
    t.float    "nightly_high_price"
    t.float    "nightly_mid_price"
    t.float    "nightly_low_price"
    t.float    "weekly_high_price"
    t.float    "weekly_mid_price"
    t.float    "weekly_low_price"
    t.string   "vrbo_id"
    t.integer  "user_id"
    t.string   "country"
    t.integer  "bedrooms"
    t.integer  "bathrooms"
    t.integer  "adults"
    t.integer  "kids"
    t.boolean  "balcony",              :default => false
    t.boolean  "dishwasher",           :default => false
    t.boolean  "fireplace",            :default => false
    t.boolean  "hardwood_floors",      :default => false
    t.boolean  "patio",                :default => false
    t.boolean  "refrigerator",         :default => false
    t.boolean  "microwave",            :default => false
    t.boolean  "washer_dryer",         :default => false
    t.boolean  "clubhouse",            :default => false
    t.boolean  "exercise_room",        :default => false
    t.boolean  "on_site_laundry",      :default => false
    t.boolean  "on_site_manager",      :default => false
    t.boolean  "security_gate",        :default => false
    t.boolean  "swimming_pool",        :default => false
    t.boolean  "tennis_courts",        :default => false
    t.boolean  "parking",              :default => false
    t.boolean  "wifi",                 :default => false
    t.string   "unit_other"
    t.string   "building_other"
    t.integer  "floors"
    t.integer  "located_on_floor"
    t.string   "year_built"
    t.string   "sq_footage"
    t.boolean  "featured",             :default => false
  end

  add_index "rental_units", ["fb_user_id"], :name => "index_rental_units_on_fb_user_id"

  create_table "reservations", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "status"
    t.text     "notes"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "mobile"
    t.string   "fax"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "inquiry_source"
    t.integer  "number_of_adults",   :default => 0
    t.integer  "number_of_children", :default => 0
    t.string   "remote_id"
    t.integer  "rental_unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "booking_id"
  end

  create_table "rewards", :force => true do |t|
    t.integer  "user_id"
    t.integer  "booking_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_fb_streams", :force => true do |t|
    t.integer  "user_id"
    t.integer  "rental_unit_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.datetime "authorized_at"
    t.string   "fb_user_id"
    t.datetime "fb_updated_at"
    t.string   "session_key"
    t.datetime "session_expires_at"
    t.string   "app_api_key"
    t.string   "authorize_signature"
    t.text     "linked_account_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "vrbo_login"
    t.string   "vrbo_password"
    t.float    "redeemed_rewards"
    t.string   "twitter_secret"
    t.string   "twitter_token"
    t.string   "twitter_name"
    t.string   "first_name"
    t.string   "middle_initial"
    t.string   "last_name"
    t.string   "company"
    t.boolean  "use_fb_profile",        :default => false
    t.datetime "last_poll_time"
    t.string   "phone"
    t.time     "sms_starting_at"
    t.time     "sms_ending_at"
    t.text     "fb_friend_ids"
    t.string   "fb_location"
    t.datetime "fb_location_update_at"
    t.string   "fb_lng"
    t.string   "fb_lat"
    t.string   "subscription_plan"
    t.boolean  "valid_country",         :default => false
    t.boolean  "update_twitter",        :default => false, :null => false
    t.boolean  "update_fb_wall",        :default => false, :null => false
  end

  add_index "users", ["fb_user_id"], :name => "index_users_on_fb_user_id"

  create_table "youtube_tokens", :force => true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
