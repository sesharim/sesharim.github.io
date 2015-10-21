lock '3.4.0'
server '107.170.122.37', user: 'root', roles: %w{app db web}

set :application, 'CustomGears'
set :repo_url, 'git@github.com:sesharim/customgears.git'
set :branch, :master
set :deploy_to, '/home/rails'
set :scm, :git
set :user, :root
set :use_sudo, false

set :format, :pretty
set :keep_releases, 3
set :log_level, :info
set :pty, true

set :ssh_options, {
 forward_agent: true
}

before 'deploy:update', 'deploy:update_jekyll'

namespace :deploy do
  [:start, :stop, :restart, :finalize_update].each do |t|
    desc "#{t} task is a no-op with jekyll"
    task t, :roles => :app do ; end
  end

  desc 'Run jekyll to update site before uploading'
  task :update_jekyll do
    # clear existing _site
    # build site using jekyll
    # remove Capistrano stuff from build
    %x(rm -rf _site/* && jekyll build && rm _site/Capfile && rm -rf _site/config)
  end
end
