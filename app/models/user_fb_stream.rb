class UserFbStream < ActiveRecord::Base
  belongs_to :user
  belongs_to :rental_unit
  
  scope :for_user, lambda {|u| where("user_id = ?", u.id) }
end
