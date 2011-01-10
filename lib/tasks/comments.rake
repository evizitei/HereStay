namespace :comments do
  desc "Load fb comments."
  task :load => :environment do
    RentalUnit.all.each do |rental_unit|
      oauth = Koala::Facebook::OAuth.new(Facebook::APP_ID.to_s, Facebook::SECRET.to_s)
      token = oauth.get_app_access_token
      comments = Koala::Facebook::RestAPI.new(token).fql_query("select xid, object_id, post_id, fromid, time, text, id, username, reply_xid  from comment where xid  = 'here_stay_unit_#{rental_unit.id}'")
      comments.each do |comment|
        user = User.find_by_fb_user_id(comment['fromid'].to_s)
        rental_unit.comments.create(:user_id => (user.nil? ? nil : user.id), 
                                :fb_user_id => comment['fromid'],
                                :fb_id => comment['id'],
                                :text => comment['text'],
                                :time => Time.at(comment['time'])                                
                                )
      end
    end
  end
end