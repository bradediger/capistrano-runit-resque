require 'capistrano/runit'
require 'erb'
require 'capistrano/runit/resque_helper'
load File.expand_path('../../tasks/resque.rake', __FILE__)
