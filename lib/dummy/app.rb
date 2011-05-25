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
require 'dummy/sandbox'
require 'dummy/update'
require 'dummy/install'
require 'dummy/release'
require 'dummy/generate'

module Dummy
  class App < Thor::Group
    include Thor::Actions
    check_unknown_options!

    def self.source_root
      @_source_root ||= File.expand_path('../templates', __FILE__)
    end

    argument      :app_command,  :type => :string, :default => 'sandbox', 
                                :desc => "Dummy App command: sandbox, export, import, gems, generate, update, release"

    class_option  :sandbox,  :type => :string, :default => "~/rails-dummies", :aliases => "-s",
                                :desc => "Where to sandbox rails dummy apps"

    class_option  :orms,     :type => :array,  :default => [], :aliases => "-o",
                                :desc => "Only effect dummy apps matching these orms"

    class_option  :gems,     :type => :array,  :default => [], :aliases => "-g",
                                :desc => "Gems to insert in dummy apps"

    class_option  :github,   :type => :string, :default => true, :aliases => "-h",
                                :desc => "Release: github account." 

    class_option  :bundle,   :type => :boolean, :default => true, :aliases => "-b",
                                :desc => "Export: run bundle after export" 

    class_option  :command,  :type => :string, :aliases => "-c",
                                :desc => "Sandbox: run command in sandbox" 
                                                              
    desc "Executes a command on one or more dummy apps"

    def invoke_rails_app_generators
      if !has_dummy_apps_dir? 
        say "dummy must be run from the Rails application root", :red
        exit(0)
      end
    
      if !valid_command?
        say "The command #{app_command} was not recognized, please use one of: #{valid_commands.join(', ')}", :red
        exit(0)
      end
    
      invoke command_class, app_args
    end

    protected

    def valid_commands
      [:sandbox, :export, :import, :gems, :generate, :update, :install, :release]
    end

    def valid_command?
      valid_commands.include? command_sym
    end      

    def command_sym
      app_command.downcase.to_sym
    end

    def app_args
      args = case command_sym
      when :sandbox
        "--command #{command}"
      when :export, :import
        "--sandbox #{sandbox} --bundle #{bundle}"
      when :generate
        "--command #{command}"        
      when :update
      when :install
        "--gems #{gems}"
      when :release
        "--github #{github}"
      end
      args << "--orms #{orms}"
    end

    def self.class_options
      [:sandbox, :gems, :command, :github, :orms, :bundle]
    end

    class_options.each do |clsopt|
      class_eval %{
        def #{clsopt}
          options[:#{clsopt}]
        end        
      }
    end

    def command_class
      "DummyApp::#{command_class}".constantize
    end

    def command_class
      command.camelize
    end

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
