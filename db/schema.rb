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

ActiveRecord::Schema.define(:version => 20101122132749) do

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
  end

  add_index "users", ["fb_user_id"], :name => "index_users_on_fb_user_id"

  create_table "youtube_tokens", :force => true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
