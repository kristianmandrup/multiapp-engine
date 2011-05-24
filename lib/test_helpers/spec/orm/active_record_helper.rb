# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require 'dummy-apps/#dummy_app_name#/config/environment.rb'
require 'spec_init'
# Run any available migration  
ActiveRecord::Migrator.migrate 'dummy-apps/#dummy_app_name#/db/migrate'
require 'spec_config'