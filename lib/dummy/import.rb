require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'

# The problem is, that the rails command doesn't work right within a directory with its own Gemfile. 
# You need to first export the app to a sandbox, then run any bundle or rails commands:

# - $ bundle ...
# - $ rails new ...
# - $ rails g ...

# This functionality should be integrated into _export_ and _import_ commands of the *dummy* executable (and DummyApp generator).
# @dummy export cancan_active_record ~/rails-dummies [--bundle]@

module Dummy   
  autoload :Helper,     'dummy/helper'
  
  class Import < Thor::Group
    include Thor::Actions
    check_unknown_options!

    def self.source_root
      @_source_root ||= File.expand_path('../../templates', __FILE__)
    end

    argument      :apps,     :type => :array,  :default => [], 
                                :desc => "Dummy apps to export"

    class_option  :sandbox,  :type => :string, :default => "~/rails-dummies", :aliases => "-s",
                                :desc => "Where to sandbox rails dummy apps"

    class_option  :bundle,   :type => :boolean, :default => true, :aliases => "-b",
                                :desc => "Export: run bundle after export" 
                                                              
    desc "Import a dummy app from sandbox to dummy-apps folder"

    def set_root
      self.destination_root = File.expand_path(destination_root)
    end

    def check!
      if !has_dummy_apps_dir? 
        say "dummy must be run from the Rails application root", :red
        exit(0)
      end
    end

    def import
      FileUtils.cd sandbox_location
      bundle_install(bundle)
      matching_dummy_apps.each do |dummy_app|
        FileUtils.mv dummy_app, dummy_apps_dir
      end            
    end

    protected

    def self.class_options
      [:sandbox, :bundle]
    end
    
    include Dummy::Helper    
  end
end


