require 'capistrano/runit'
require 'erb'
load File.expand_path('../../tasks/resque_scheduler.rake', __FILE__)