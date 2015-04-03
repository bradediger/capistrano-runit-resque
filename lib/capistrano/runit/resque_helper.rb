module Capistrano
  module Runit
    module ResqueHelper
      def resque_environment
        @resque_environment ||= fetch(:rack_env, fetch(:rails_env, 'production'))
      end

      def output_redirection
        ">> #{fetch(:runit_resque_log_file)} 2>> #{fetch(:runit_resque_log_file)}"
      end
    end
  end
end