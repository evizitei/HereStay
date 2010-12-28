require 'rubygems'

set :stages, %w(production)
set :default_stage, "production"
require 'capistrano/ext/multistage'

set :application, "herestay"
set :repository, "git@github.com:Jazzcloud/HereStay.git"

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }
set :run_method, :run

set :scm, :git
set :deploy_via, :remote_cache

after 'deploy:update_code', 'deploy:link_db_config'
# after 'deploy:update_code', 'deploy:update_crontab'
after 'deploy:update_code', 'bundler:bundle_new_release'
after 'deploy:default', 'deploy:restart'

namespace :deploy do
  # task :default do
  #   update
  #   migrate
  #   restart
  #   update_crontab
  # end

  desc "Restart Application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  desc "Create database.yml symlink"
  task :link_db_config, :roles => :app do
    run "ln -fs #{shared_path}/database.yml #{current_release}/config/database.yml"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :app do
    run "cd #{release_path} && whenever --update-crontab #{application} --set environment=#{rails_env}"
  end

  task :resize_assets, :roles => [:app] do
    run "cd #{current_path} && rake paperclip:refresh:thumbnails CLASS=Photo RAILS_ENV=#{rails_env}"
  end
  
  # Run rake task. ex: cap production deploy:rake TASK="tulp:after_load"
  task :rake, :roles => [:app] do
    run "cd #{current_path} && rake #{ENV['TASK']} RAILS_ENV=#{rails_env}"
  end

end

desc "Generate a maintenance.html to disable requests to the application. Ex.: cap production deploy:web:disable TEMPLATE=public/rebith.html"
deploy.web.task :disable, :roles => :web do
  remote_path = "#{shared_path}/system/maintenance.html"
  on_rollback { run "rm #{remote_path}" }
  tpl = ENV['TEMPLATE'] ? ENV['TEMPLATE'] : disable_template
  template = File.read(tpl)

  deadline, reason = ENV["UNTIL"], ENV["REASON"]

  maintenance = ERB.new(template).result(binding)
  put maintenance, "#{remote_path}", :mode => 0644
end


namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without \"test development cucumber\" --deployment --path ~/.bundler_gems RAILS_ENV=#{rails_env}"
  end
end

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end