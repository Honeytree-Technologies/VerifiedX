# config valid for current version and patch releases of Capistrano
lock "~> 3.17.1"
set :repo_url, ENV.fetch('REPO')
set :branch, ENV.fetch('BRANCH')
server ENV.fetch('DEPLOY_SERVER'), user: ENV.fetch('SERVER_USER'), roles: %w{app web db}, port: ENV.fetch('SSH_PORT')
set :application, ENV.fetch('APPLICATION_NAME')
set :deploy_to, ENV.fetch('DEPLOY_TO')
set :stage, :production
set :migration_role, :app
set :puma_bind, ENV.fetch('PUMA_SOCK')
set :puma_enable_socket_service, true
set :puma_user, fetch(:user)
set :puma_role, :web
set :puma_service_unit_env_files, []
set :puma_service_unit_env_vars, []
set :sidekiq_service_unit_user, :system
set :puma_systemctl_user, :system
set :puma_service_unit_name, ENV.fetch('PUMA_SERVICE_NAME')

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/application.yml'

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do
  desc 'Initial deployment'
  task :initial do
    on roles(:app) do
      before 'deploy:migrate', 'deploy:db_create'
      after 'deploy:migrate', 'deploy:searchkick_reindex_task'
      invoke 'deploy'
    end
  end
  desc 'Run db:create task before migration'
  task :db_create do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:create'
        end
      end
    end
  end

  desc 'Run searchkick:reindex:all task after deploy:migrate'
  task :searchkick_reindex_task do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'searchkick:reindex:all'
        end
      end
    end
  end
end