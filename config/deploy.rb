require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'

set :domain, '198.20.105.55'
set :deploy_to, '/home/ws'
set :repository, 'https://github.com/airled/websockets-proxy'
set :branch, 'master'
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log']
set :user, 'ws'

task :environment do
  invoke :'rbenv:load'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'."]
  if repository
    repo_host = repository.split(%r{@|://}).last.split(%r{:|\/}).first
    repo_port = /:([0-9]+)/.match(repository) && /:([0-9]+)/.match(repository)[1] || '22'
    queue %[
      if ! ssh-keygen -H  -F #{repo_host} &>/dev/null; then
        ssh-keyscan -t rsa -p #{repo_port} -H #{repo_host} >> ~/.ssh/known_hosts
      fi
    ]
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
  end
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'
    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
    end
  end
end

desc "Starts the application remotely."
task :start => :environment do
  queue "cd current && rake start"
end

desc "Stops the application remotely."
task :stop => :environment do
  queue "cd current && rake stop"
end

desc "Restarts the application remotely."
task :restart => :environment do
  queue "cd current && rake restart"
end
