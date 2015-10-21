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

namespace :deploy do
  task :update_jekyll do
    on roles(:app) do
      within "#{deploy_to}/current" do
        execute :jekyll, "build"
      end
    end
  end

end

after "deploy:symlink:release", "deploy:update_jekyll"
