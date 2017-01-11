# lock '3.6.1'

server '107.170.122.37', user: 'root', roles: %w{app db web}

set :application, 'brandservice'
set :repo_url, 'git@github.com:Aejis/brandservice.git'
set :branch, :production
set :deploy_to, '/home/rails/apps/'

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
