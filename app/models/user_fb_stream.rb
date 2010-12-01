class UserFbStream < ActiveRecord::Base
  belongs_to :user
  belongs_to :rental_unit
  
  validates_numericality_of :user_id, :rental_unit_id, :allow_nil => false
  validates_presence_of :message
  
  scope :for_user, lambda {|u| where("user_id = ?", u.id) }
end
