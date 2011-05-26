require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'

require 'dummy/export'
require 'dummy/import'

# The problem is, that the rails command doesn't work right within a directory with its own Gemfile. 
# You need to first export the app to a sandbox, then run any bundle or rails commands:

# - $ bundle ...
# - $ rails new ...
# - $ rails g ...

# This functionality should be integrated into _export_ and _import_ commands of the *dummy* executable (and DummyApp generator).
# @dummy export cancan_active_record ~/rails-dummies [--bundle]@

module Dummy
  class Install < Thor::Group
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

    class_option  :gems,     :type => :array, :default => [], :aliases => "-o",
                                :desc => "Orms to match on dummy apps" 
                                                              
    desc "Run a command on a dummy app in the sandbox"

    def set_root
      self.destination_root = File.expand_path(destination_root)
    end

    def sandbox_exec
        export_apps

        matching_dummy_apps.each do |app|
          FileUtils.cd sandbox_app_dir(app)
          insert_gems_for
          bundle_install
          install_gems
        end

        import_apps
      end            
    end

    protected

    def export_apps
      invoke Dummy::Export, command_args
    end

    def command_args
      args = [matching_dummy_apps]
      args << "--sandbox #{sandbox}" if !sandbox.empty?
      args
    end

    def import_apps
      invoke Dummy::Import, command_args
    end

    def insert_gems_for
      say "Inserting gems into Gemfile: #{gems}"
      append_to_file gemfile, gems.maps{|gm| "gem '#{gm}'" }.join("\n")
    end

    def install_gems
      gems.each do |gm|
        exec "rails g #{gm}:install"
        exec "rails g #{gm}:config"
      end
    end

    def sandbox_app_dir app
      File.join(sandbox_location, app)
    end

    def self.class_options
      [:sandbox, :orms, :gems]
    end 
    
    include Dummy::Helper       
  end
end


