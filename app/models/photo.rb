class Photo < ActiveRecord::Base
  has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                      :storage => :s3,:s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                      :path => "child/:attachment/:id/:style/:basename.:extension",
                      :s3_host_alias => "s3.micasa-fb.com", 
                      :bucket => "s3.micasa-fb.com", 
                      :url=>":s3_alias_url"
                      
  belongs_to :rental_unit
end
