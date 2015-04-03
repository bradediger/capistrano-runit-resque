# capistrano-runit-resque

Capistrano3 tasks for manage resque and resque-scheduler via runit supervisor.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-runit-resque'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-runit-resque

Add this line in `Capfile`:
```ruby
require 'capistrano/runit/resque' # Resque support
require 'capistrano/runit/resque_scheduler' # Resque Scheduler support
```

## Variables

### General

* `runit_resque_log_file` -- Path to log file. Default value: `shared/log/resque.production.log`
* `runit_resque_interval` -- Interval in seconds for checking new jobs/scheduled jobs. Default value: `5`
* `runit_resque_environment_task` -- Load Rails environment task or not. Default value: `true`
* `runit_resque_verbose` -- Verbose logging into log file. Default value: `true`

### Resque

* `runit_resque_default_hooks` -- run default hooks for runit resque or not. Default value: `true`.
* `runit_resque_role` -- Role on where resque will be running. Default value: `:app`

### Resque scheduler

* `runit_resque_scheduler_default_hooks` -- run default hooks for runit resque or not. Default value: `true`.
* `runit_resque_scheduler_role` -- Role on where resque-scheduler will be running. Default value: `:app`
* `runit_resque_scheduler_dynamic` -- Enables dynamic scheduling if non-empty. Default value: `false`

## Tasks

* `runit:resque:setup` -- setup resque runit service.
* `runit:resque:general:enable` -- enable and autostart service for all jobs.
* `runit:resque:general:disable` -- stop and disable service for all jobs.
* `runit:resque:general:start` -- start service for all jobs.
* `runit:resque:general:stop` -- stop service for all jobs.
* `runit:resque:general:restart` -- restart service for all jobs.

And there is a list of tasks what is depend on your workers.

## Contributing

1. Fork it ( https://github.com/capistrano-runit/resque/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
