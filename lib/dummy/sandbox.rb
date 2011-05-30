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

  class Sandbox < Thor::Group
    include Thor::Actions
    check_unknown_options!

    def self.source_root
      @_source_root ||= File.expand_path('../../templates', __FILE__)
    end

    argument      :apps,      :type => :array,  :default => [], :required => false,
                                :desc => "Dummy apps to act on"

    class_option  :sandbox,   :type => :string, :default => nil, :aliases => "-s",
                                :desc => "Where to sandbox rails dummy apps"

    class_option  :orms,      :type => :array, :default => [], :aliases => "-o",
                                :desc => "Orms to match on dummy apps" 

    class_option  :command,   :type => :string, :aliases => "-c", # :required => true,
                                :desc => "Command to run on each dummy app" 

    class_option  :bundle,    :type => :boolean, :aliases => "-b",
                                :desc => "Bundle after run?" 
                                                              
    desc "Run a command on a dummy app in the sandbox"

    def set_root
      self.destination_root = File.expand_path(destination_root)
    end

    def sandbox_exec 
      say "Sandbox Command: #{command}"
      say "Sandbox Apps: #{apps}"
      puts "matching apps: #{matching_dummy_apps}"      
      apps = matching_dummy_apps
      export_apps apps

      apps.each do |dummy_app|
        exec command
      end            
      
      import_apps apps
    end

    protected

    def export_apps exp_apps
      say "Export apps: #{exp_apps}"
      exp_apps.each do |app|   
        src = dummy_app_path(app)
        target = sandbox_app_path
        puts "src: #{src}, targ: #{target}"
        sandbox_app_dir = sandbox_app_path(short_name app)
        if File.directory?(sandbox_app_dir)
          puts "removed in sandbox"
          FileUtils.rm_rf(sandbox_app_dir) 
        end                                 
        if File.directory?(src) && File.directory?(target)
          puts "moved to sandbox"
          FileUtils.mv(src, sandbox_app_path) 
        end
      end
    end

    def dummy_app_path name
      File.join(dummy_apps_path, name)
    end

    def dummy_apps_path
      File.join(destination_root, "spec/dummy-apps")
    end

    def import_apps imp_apps
      say "Import apps: #{imp_apps}"
      imp_apps.each do |app|
        src = sandbox_app_path(short_name app)
        target = dummy_apps_path

        puts "scr #{src} not found" if !File.directory?(src) 
        puts "target #{target} not found" if !File.directory?(target)

        if File.directory?(src) && File.directory?(target)
          puts "moving from sandbox"
          FileUtils.mv src, target
        else
          puts "not found!"
        end
      end      
    end

    def export_app
      invoke Dummy::Export, command_args
    end

    def command_args
      args = [matching_dummy_apps]
      args << make_arg(:sandbox) if !sandbox.empty?
      args
    end

    def import_app
      invoke Dummy::Import, command_args
    end
    
    # def self.class_options
    #   [:sandbox, :orms, :command]
    # end  

    # class_options.each do |clsopt|
    #   class_eval %{
    #     def #{clsopt}
    #       options[:#{clsopt}]
    #     end        
    #   }
    # end

    include Mengine::Base    
    include Dummy::Helper                
  end
end
