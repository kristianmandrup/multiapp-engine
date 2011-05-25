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
  autoload :Sandbox ,   'dummy/sandbox'

  class Generate < Thor::Group
    include Thor::Actions
    check_unknown_options!

    def self.source_root
      @_source_root ||= File.expand_path('../templates', __FILE__)
    end

    argument      :apps,     :type => :array,  :default => [], 
                                :desc => "Dummy apps to export"

    class_option  :sandbox,  :type => :string, :default => "~/rails-dummies", :aliases => "-s",
                                :desc => "Where to sandbox rails dummy apps"

    class_option  :orms,     :type => :array, :default => [], :aliases => "-o",
                                :desc => "Orms to match on dummy apps" 

    class_option  :command,  :type => :string, :aliases => "-c",
                                :desc => "Command to run on each dummy app" 
                                                              
    desc "Run a command on a dummy app in the sandbox"

    def set_root
      self.destination_root = File.expand_path(destination_root)
    end

    def exec_generate
      if !has_dummy_apps_dir? 
        say "dummy must be run from the Rails application root", :red
        return
      end
      
      invoke sandbox_generator, sandbox_generate_args
    end

    protected

    def sandbox_generate_args
      args = [matching_dummy_apps, "-c #{command}"]
      args << "--sandbox #{sandbox}" if !sandbox.empty?
      args      
    end

    def sandbox_generator
      Dummy::Sandbox      
    end

    def matching_dummy_apps
      dummy_apps.select {|app| matches_any_orm?(app, orms) }
    end

    def matches_any_orm? app, orms
      orms.any? {|orm| app =~ /#{orm}$/ }       
    end

    def dummy_apps
      FileList.new "dummy-*"
    end

    def self.class_options
      [:sandbox, :orms, :command]
    end

    def sandbox_location
      @sandbox_location ||= sandbox || '~/rails-dummies'
    end      

    class_options.each do |clsopt|
      class_eval %{
        def #{clsopt}
          options[:#{clsopt}]
        end        
      }
    end 

    def dummy_apps_dir
      File.join(destination_root, dummy_apps_dir_relative)
    end

    def dummy_apps_dir_relative    
      File.join(app_test_path, 'dummy-apps')
    end

    def has_dummy_apps_dir?       
      File.directory? dummy_apps_dir
    end

    def app_test_path
      return 'test' if File.directory?('test')
      return 'spec' if File.directory?('spec')
      say "You must have a /spec or /test directory in the root of your project", :red
      raise "No test or spec dir found in project"
    end
  end
end


