set :rails_env, "production"
set :domain, "69.164.216.162"
# set :port, "1020"

set :deploy_to, "/home/herestay/#{application}"
role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :user, "herestay"
set :use_sudo, false
set :branch, "master"

after "deploy", "deploy:cleanup"