include ::Capistrano::Runit
include ::Capistrano::Runit::ResqueHelper

namespace :load do
  task :defaults do
    set :runit_resque_scheduler_default_hooks, -> { true }
    set :runit_resque_scheduler_role, -> { :app }
    set :runit_resque_scheduler_dynamic, -> { false }
  end
end

namespace :deploy do
  before :starting, :runit_check_resque_schduler_hooks do
    invoke 'runit:resque_scheduler:add_default_hooks' if fetch(:runit_resque_scheduler_default_hooks)
  end
end

namespace :deploy do
  before :starting, :runit_check_resque_scheduler_hooks do
    invoke 'runit:resque_scheduler:add_default_hooks' if fetch(:runit_resque_scheduler_default_hooks)
  end
end

namespace :runit do
  namespace :resque_scheduler do
    # Helpers

    def resque_scheduler_enabled_service_dir
      enabled_service_dir_for('resque_scheduler')
    end

    def resque_scheduler_service_dir
      service_dir_for('resque_scheduler')
    end

    def collect_resque_scheduler_run_command
      array = []
      array << env_variables
      array << "RAILS_ENV=#{resque_environment}"
      array << "INTERVAL=#{fetch(:runit_resque_interval)}"
      array << 'VERBOSE=1' if fetch(:runit_resque_verbose)
      array << 'DYNAMIC_SCHEDULE=yes' if fetch(:runit_resque_scheduler_dynamic)
      array << "exec #{SSHKit.config.command_map[:rake]} #{"environment" if fetch(:runit_resque_environment_task)} resque:scheduler"
      array << output_redirection
      array.compact.join(' ')
    end

    task :add_default_hooks do
      after 'deploy:check', 'runit:resque_scheduler:check'
      after 'deploy:updated', 'runit:resque_scheduler:stop'
      after 'deploy:reverted', 'runit:resque_scheduler:stop'
      after 'deploy:published', 'runit:resque_scheduler:start'
    end

    task :check do
      check_service('resque_scheduler')
    end

    desc 'Setup resque_scheduler runit service'
    task :setup do
      setup_service('resque_scheduler', collect_resque_scheduler_run_command)
    end

    desc 'Enable resque_scheduler runit service'
    task :enable do
      enable_service('resque_scheduler')
    end

    desc 'Disable resque_scheduler runit service'
    task :disable do
      disable_service('resque_scheduler')
    end

    desc 'Start resque_scheduler runit service'
    task :start do
      start_service('resque_scheduler')
    end

    desc 'Stop resque_scheduler runit service'
    task :stop do
      stop_service('resque_scheduler', false)
    end

    desc 'Restart resque_scheduler runit service'
    task :restart do
      restart_service('resque_scheduler')
    end

  end
end