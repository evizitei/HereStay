class User < ActiveRecord::Base
  has_many :discounts
end
