require 'capistrano/runit'
require 'erb'
require 'capistrano/runit/resque_helper'
load File.expand_path('../../tasks/resque_scheduler.rake', __FILE__)