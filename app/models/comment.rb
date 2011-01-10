class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :rentals_unit
  
  validates_presence_of :text, :fb_id, :fb_user_id, :time
  validates_numericality_of :rental_unit_id, :allow_blank => false
  validates_numericality_of :user_id, :allow_nil => true
  validates_uniqueness_of :fb_id
end
