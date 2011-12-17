load 'deploy' if respond_to?(:namespace) # cap2 differentiator

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

require 'bundler/capistrano'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :application, "cnintridea"
set :repository,  "git://github.com/intridea-east/cnintridea.git"

set :scm, :git
set :branch, 'master'
set :checkout, 'export'
set :deploy_via, :remote_cache
set :keep_releases, 3

set :user, 'app'
set :use_sudo, false
server "cn.intridea.com", :app

namespace :deploy do
  task :compile do
    run "cd #{current_release} && bundle exec rake generate"
  end

  desc <<-DESC
    Present a maintenance page to visitors. Disables your application's web \
    interface by writing a "maintenance.html" file to each web server. The \
    servers must be configured to detect the presence of this file, and if \
    it is present, always display it instead of performing the request.

    By default, the maintenance page will just say the site is down for \
    "maintenance", and will be back "shortly", but you can customize the \
    page by specifying the REASON and UNTIL environment variables:

      $ cap deploy:web:disable \\
            REASON="a hardware upgrade" \\
            UNTIL="12pm Central Time"

    Further customization will require that you write your own task.
  DESC
  task :disable do
    on_rollback { run "rm -f #{shared_path}/system/maintenance.html" }
    template = File.read('./source/_layouts/maintenance.html.erb')

    test = 1
    page = begin
             deadline = ENV['UNTIL']
             reason = ENV['reason']
             ERB.new(template).result(binding)
           end

    put page, "#{shared_path}/system/maintenance.html", :mode => 0644
  end
  desc "Quit maintenance"
  task :enable do
    run "rm -f #{shared_path}/system/maintenance.html"
  end
end

after 'deploy:update_code', 'deploy:compile'
