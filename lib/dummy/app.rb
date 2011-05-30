require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'

module Dummy
  autoload :Export,     'dummy/export'
  autoload :Generate,   'dummy/generate'
  autoload :Import,     'dummy/import'
  autoload :Install,    'dummy/install'
  autoload :Release,    'dummy/release'
  autoload :Sandbox ,   'dummy/sandbox'
  autoload :Update ,    'dummy/update'
  autoload :Helper ,    'dummy/helper'
  autoload :Create ,    'dummy/create'
  autoload :OrmConf ,   'dummy/orm_conf'

  class App < Thor::Group
    include Thor::Actions
    # check_unknown_options!

    def self.source_root
      @_source_root ||= File.expand_path('../templates', __FILE__)
    end

    argument      :app_command,   :type => :string, :default => 'sandbox', 
                                  :desc => "Dummy App command: sandbox, export, import, gems, generate, update, release"

    class_option  :sandbox,       :type => :string, :default => nil, :aliases => "-s",
                                  :desc => "Where to sandbox rails dummy apps"

    class_option  :apps,          :type => :array,  :default => [], :aliases => "-a",
                                  :desc => "Dummy Apps to affect"

    class_option  :orms,          :type => :array,  :default => [], :aliases => "-o",
                                  :desc => "Only effect dummy apps matching these orms"

    class_option  :gems,          :type => :array,  :default => [], :aliases => "-g",
                                  :desc => "Gems to insert in dummy apps"

    class_option  :github,        :type => :string, :default => true, :aliases => "-h",
                                  :desc => "Release: github account." 

    class_option  :bundle,        :type => :boolean, :default => true, :aliases => "-b",
                                  :desc => "Export: run bundle after export" 

    class_option  :command,       :type => :string, :aliases => "-c",
                                  :desc => "Sandbox: run command in sandbox" 

    class_option  :opts,          :type => :string, :aliases => "-o",
                                    :desc => "Create: options to command" 

                                                              
    desc "Executes a command on one or more dummy apps"

    def invoke_command 
      say "Command: #{command}"
      
      if !has_dummy_apps_dir? 
        say "dummy must be run from the Rails application root", :red
        return
      end
          
      if !valid_command?
        say "The command #{app_command} was not recognized, please use one of: #{valid_commands.join(', ')}", :red
        return
      end

      say "invoking #{app_command_class} #{app_args.inspect}", :green 
          
      invoke app_command_class, app_args
    end

    protected
    
    def app_args
      args = apps.blank? ? [] : [apps] 
      command_args = case command_sym
      when :sandbox
        make_arg :command
      when :export, :import
        make_arg :bundle
      when :generate
        make_arg :command
      when :update
      when :install
        make_arg :gems
      when :release
        make_arg :github
      when :create
        make_arg :opts
      when :ormconf
        nil        
      end
      args << command_args if command_args      
      args << make_arg(:sandbox) if !sandbox.empty?
      args << make_arg(:orms) if !orms.empty? 
      args
    end

    def apps
      options[:apps].empty? ? "" : options[:apps].join(' ')
    end

    def app_command_class
      "Dummy::#{app_command_class_name}".constantize
    end
    
    def app_command_class_name
      app_command.camelize
    end    
        
    def command_sym
      app_command.downcase.to_sym
    end  

    def valid_command?
      valid_commands.include? command_sym
    end      

    def valid_commands
      [:sandbox, :export, :import, :gems, :generate, :update, :install, :release, :create, :ormconf]
    end
    
    def self.command_options
      [:sandbox, :gems, :command, :github, :orms, :bundle, :opts]
    end

    include Dummy::Helper        
  end
end
