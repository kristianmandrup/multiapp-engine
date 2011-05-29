require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'
require 'mengine/base'

# The problem is, that the rails command doesn't work right within a directory with its own Gemfile. 
# You need to first export the app to a sandbox, then run any bundle or rails commands:

# - $ bundle ...
# - $ rails new ...
# - $ rails g ...

# This functionality should be integrated into _export_ and _import_ commands of the *dummy* executable (and DummyApp generator).
# @dummy export cancan_active_record ~/rails-dummies [--bundle]@

module Dummy
  autoload :Export,     'dummy/export'
  autoload :Import,     'dummy/import'
  autoload :Helper,     'dummy/helper'

  class Update < Thor::Group
    include Thor::Actions
    check_unknown_options!

    def self.source_root
      @_source_root ||= File.expand_path('../../templates', __FILE__)
    end

    argument      :apps,     :type => :array,  :default => [], 
                                :desc => "Dummy apps to export"

    class_option  :sandbox,  :type => :string, :default => "~/rails-dummies", :aliases => "-s",
                                :desc => "Where to sandbox rails dummy apps"

    class_option  :orms,     :type => :array, :default => [], :aliases => "-o",
                                :desc => "Orms to match on dummy apps" 


    # figure out depending on which directory already exists!
    # class_option :test_framework, :default => "rspec", :aliases => "-t",
    #                               :desc => "Test framework to use. test_unit or rspec."
                                                              
    desc "Run a command on a dummy app in the sandbox"

    def set_root
      self.destination_root = File.expand_path(destination_root)
    end

    def sandbox_exec
      matching_dummy_apps.each do |dummy_app|
        export_app dummy_app
        bundle_update
        import_app dummy_app
      end            
    end

    protected

    include Mengine::Base

    def self.class_options
      [:sandbox, :orms]
    end
    
    include Dummy::Helper    
  end
end


