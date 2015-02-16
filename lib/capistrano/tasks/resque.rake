include ::Capistrano::Runit

namespace :load do
  task :defaults do
    set :runit_resque_run_template, nil
    set :runit_resque_default_hooks, -> { true }
    set :runit_resque_role, -> { :app }
    set :runit_resque_workers, -> { {'*' => 1} }
    set :runit_resque_interval, "5"
    set :runit_resque_environment_task, false
    set :runit_resque_kill_signal, -> { 'QUIT' }
  end
end

namespace :deploy do
  before :starting, :runit_check_resque_hooks do
    invoke 'runit:resque:add_default_hooks' if fetch(:runit_resque_default_hooks)
  end
end

namespace :runit do
  namespace :resque do
    # Helpers
    def collect_resque_run_command(queue)
      array = []
      array << env_variables
      array << "RAILS_ENV=#{resque_environment}"
      array << "INTERVAL=#{fetch(:runit_resque_interval)}"
      array << "QUEUE=#{queue}"
      array << "VERBOSE=1"
      array << "exec #{SSHKit.config.command_map[:rake]} #{"environment" if fetch(:runit_resque_environment_task)} resque:work"
      array.compact.join(' ')
    end

    def resque_environment
      @resque_environment ||= fetch(:rack_env, fetch(:rails_env, 'production'))
    end

    def resque_runit_stop_commamd
      @resque_runit_stop_command ||= case fetch(:runit_resque_kill_signal)
                                     when 'QUIT', 'TERM', 'KILL', 'CONT'
                                       fetch(:runit_resque_kill_signal).downcase
                                     when 'USR1'
                                       '1'
                                     when 'USR2'
                                       '2'
                                     when 'INT'
                                       'interrupt'
                                     end
    end

    def generate_namespace_for_resque_task(name, queue, count, parent_task)
      my_namespace = "runit:resque:#{name}"
      parent_task.application.define_task Rake::Task, "#{my_namespace}:setup" do
        count.times.each do |i|
          setup_service("resque_#{name}_#{i}", collect_resque_run_command(queue))
        end
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:enable" do
        count.times.each do |i|
          enable_service("resque_#{name}_#{i}")
        end
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:disable" do
        count.times.each do |i|
          disable_service("resque_#{name}_#{i}")
        end
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:start" do
        count.times.each do |i|
          start_service("resque_#{name}_#{i}")
        end
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:stop" do
        on roles fetch("runit_resque_#{name}_role".to_sym) do
          count.times.each do |i|
            stop_service("resque_#{name}_#{i}", false)
          end
        end
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:quiet" do
        on roles fetch("runit_resque_#{name}_role".to_sym) do
          count.times.each do |i|
            runit_execute_command("resque_#{name}_#{i}", '2')
          end
        end
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:restart" do
        count.times.each do |i|
          restart_service("resque_#{name}_#{i}")
        end
      end
    end

    task :add_default_hooks do
      after 'deploy:check', 'runit:resque:check'
      after 'deploy:starting', 'runit:resque:quiet'
      after 'deploy:updated', 'runit:resque:stop'
      after 'deploy:reverted', 'runit:resque:stop'
      after 'deploy:published', 'runit:resque:start'
    end

    task :hook do |task|
      fetch(:runit_resque_workers).each do |key, count|
        name = if key == '*'
                 'general'
               else
                 key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
               end
        set "runit_resque_#{name}_role".to_sym, -> { :app }
        generate_namespace_for_resque_task(name, key, count, task)
      end
    end

    task :check do
      fetch(:runit_resque_workers).each do |key, value|
        key = 'general' if key == '*'
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        check_service('resque', name)
      end
    end

    task :stop do
      fetch(:runit_resque_workers).each do |key, value|
        key = 'general' if key == '*'
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:resque:#{name}:stop"].invoke
      end
    end

    task :quiet do
      fetch(:runit_resque_workers).each do |key, value|
        key = 'general' if key == '*'
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:resque:#{name}:quiet"].invoke
      end
    end

    task :start do
      fetch(:runit_resque_workers).each do |key, value|
        key = 'general' if key == '*'
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:resque:#{name}:start"].invoke
      end
    end

    task :restart do
      fetch(:runit_resque_workers).each do |key, value|
        key = 'general' if key == '*'
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:resque:#{name}:restart"].invoke
      end
    end

  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'runit:resque:hook'
end