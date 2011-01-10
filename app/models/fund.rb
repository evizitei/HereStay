class Fund < ActiveRecord::Base
  belongs_to :user
  belongs_to :document, :polymorphic => true
  
end
