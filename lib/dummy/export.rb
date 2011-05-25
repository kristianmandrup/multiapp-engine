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
  class Export < Thor::Group
    include Thor::Actions
    check_unknown_options!

    def self.source_root
      @_source_root ||= File.expand_path('../templates', __FILE__)
    end

    argument      :apps,     :type => :array,  :default => [], 
                                :desc => "Dummy apps to export"

    class_option  :sandbox,  :type => :string, :default => "~/rails-dummies", :aliases => "-s",
                                :desc => "Where to sandbox rails dummy apps"

    class_option  :bundle,   :type => :boolean, :default => true, :aliases => "-b",
                                :desc => "Export: run bundle after export" 
                                                              
    desc "Exports a dummy app to the sandbox"

    def check!
      if !has_dummy_apps_dir? 
        say "dummy must be run from the Rails application root", :red
        return
      end
    end

    def export
      dummy_apps.each do |dummy_app|
        FileUtils.mv dummy_app, sandbox_location
      end
      bundle_install
    end

    protected

    def bundle_install
      if bundle?
        FileUtils.cd sandbox_location 
        exec 'bundle'
      end
    end

    def exec command
      Kernel::system command
    end        

    def dummy_apps
      FileList.new "#{dummy_apps_dir}/dummy-*"
    end

    def self.class_options
      [:sandbox, :bundle]
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
    alias_method :bundle?, :bundle

    def dummy_apps_dir
      File.join(app_test_path, 'dummy-apps')
    end

    def has_dummy_apps_dir?       
      File.directory? dummy_apps_dir
    end

    def app_test_path
      return 'test' if File.directory?('test')
      return 'spec' if File.directory?('spec')
      say "You must have a /spec or /test directory in the root of your project", :red
      exit(0)
    end
  end
end


