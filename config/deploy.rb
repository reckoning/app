# frozen_string_literal: true

set :shared_dirs, [
  'public/uploads',
  'tmp/pids',
  'tmp/sockets',
  'dumps'
]

set :shared_files, [
  '.rbenv-vars',
]

set :stages, %w[local live]
set :default_stage, 'local'

require 'mina/multistage'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

set :user, 'reckoning'
set :forward_agent, true

set :deploy_to, '/home/reckoning'
set :repository, 'https://github.com/reckoning/app.git'
set :rails_env, 'production'
set :branch, 'main'
set :version_scheme, :datetime

task :remote_environment do
  invoke :'rbenv:load'
end

desc 'Deploys the current version to the server.'
task deploy: :remote_environment do
  deploy do
    invoke :'git:clone'
    comment 'Install Latest Ruby Version'
    command %(rbenv install -s)
    comment 'Update Rubygems'
    command %(gem update --system)
    comment 'Update/Install Bundler'
    command %(gem install bundler --conservative --silent)
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'server:restart'
    end
  end
end

task assets_precompile: :remote_environment do
  in_path fetch(:current_path).to_s do
    comment %(Precompile Assets)
    command %(#{fetch(:rake)} assets:precompile)
  end
end

task assets_precompile: :remote_environment do
  in_path fetch(:current_path).to_s do
    comment %(Precompile Assets)
    command %(#{fetch(:rake)} assets:precompile)
  end
  invoke :'server:restart'
end

task console: :remote_environment do
  set :execution_mode, :exec
  in_path fetch(:current_path).to_s do
    command %(#{fetch(:rails)} console)
  end
end

namespace :server do
  task :restart do
    comment 'Restart Application'
    command %(sudo service reckoning-app restart)
    command %(sudo service reckoning-worker restart)
  end

  task :stop do
    comment 'Stopping Application'
    command %(sudo service reckoning-app stop)
    command %(sudo service reckoning-worker stop)
  end

  task :start do
    comment 'Starting Application'
    command %(sudo service reckoning-app start)
    command %(sudo service reckoning-worker start)
  end
end

namespace :bundler do
  task reinstall: :remote_environment do
    in_path fetch(:current_path).to_s do
      command %(bundle install --redownload)
    end
  end
end

namespace :db do
  task load_schema: :remote_environment do
    in_path fetch(:current_path).to_s do
      invoke :'server:stop'
      comment %(Loading Schema for database)
      command %(#{fetch(:rake)} db:schema:load)
      invoke :'server:start'
    end
  end

  task migrate: :remote_environment do
    in_path fetch(:current_path).to_s do
      comment %(Migrating database)
      command %(#{fetch(:rake)} db:migrate)
    end
  end

  task backup: :remote_environment do
    in_path fetch(:current_path).to_s do
      comment 'Creating DB Backup...'
      command %(bundle exec thor db:dump)
      comment 'DB Backup finished'
    end
  end

  task local_import: :download_backup do
    system %(pg_restore --verbose --clean --no-acl --no-owner -h localhost -d reckoning_dev dumps/latest.dump)
  end

  task download_backup: :backup do
    comment 'Downloading latest backup...'
    system %(scp #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:deploy_to)}/shared/dumps/latest.dump dumps/)
    comment 'Download finished'
  end

  # to import login with root and use:
  # pg_restore --verbose --clean --no-acl --no-owner -h 127.0.0.1 -U reckoning -d reckoning dumps/latest.dump
  # from shared dir
  task :upload_backup do
    comment 'Uploading latest backup...'
    system %(scp dumps/latest.dump #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:deploy_to)}/shared/dumps/)
    comment 'Upload finished'
  end
end
