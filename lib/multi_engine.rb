require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'
require "mengine/base"
require "mengine/templates"
require "mengine/dummy"
require "mengine/dummy_spec"
require "mengine/dummy_app"
require "mengine/orm"

class MultiEngine < Thor::Group
  include Thor::Actions
  check_unknown_options!

  def self.source_root
    @_source_root ||= File.expand_path('../templates', __FILE__)
  end

  def self.say_step(message)
    @step = (@step || 0) + 1
    class_eval <<-METHOD, __FILE__, __LINE__ + 1
      def step_#{@step}
        #{"puts" if @step > 1}
        say_status "STEP #{@step}", #{message.inspect}
      end
    METHOD
  end

  argument     :path, :type => :string,
                                :desc => "Path to the engine to be created"

  class_option :test_framework, :default => "rspec", :aliases => "-t",
                                :desc => "Test framework to use. test_unit or rspec."

  class_option :orms, :type => :array, :default => [],
                                :desc => "Datastore frameworks to use. mongoid or active_record."

  class_option :types, :type => :array, :default => [], 
                                :desc => "Dummy application names"

  class_option :tu,  :type => :boolean, :default => true,
                                :desc => "Skip testunit generation for dummy apps."

  class_option :js,  :type => :boolean, :default => true,
                                :desc => "Skip javascript generation for dummy apps."

  
  desc "Creates a Rails 3 engine with Rakefile, Gemfile and running tests."

  say_step "Creating gem skeleton"

  def create_root
    self.destination_root = File.expand_path(path, destination_root)
    set_accessors!

    directory "root", "."
    FileUtils.cd(destination_root)
  end

  def create_tests_or_specs
    directory test_path
  end

  def change_gitignore
    template "gitignore", ".gitignore"
  end

  def invoke_rails_app_generators
    say "Vendoring Rails applications at #{test_path}/dummy-apps"
    create_engine_config
     
    types.each do |type|
      say "Creating #{type} apps"
      self.current_type = type
      orms.each do |orm|

        # set dummy app and add to dummies
        engine_config.set_dummy type, orm, app_args

        # create an empty dummy folder in the test dir
        engine_config.create_empty_dummy
         
        # export empty dummy app to sandbox
        # execute rails new command (in force mode)
        # import dummy app back in
        say "Creating #{type} dummy Rails app with #{orm_name}", :green
        invoke sandbox_generator, ["--command \"#{command}\" --bundle true"]

        say "Configuring Rails app"
        # configure dummy app
        change_config_files
        # ensure dummy app class name is right
        dummy_app.ensure_class_name

        # go back to root of engine
        FileUtils.cd(destination_root)
      end
    end
  end
  
  def configure_app_for_orms
    # for each orm
    orms.each do |orm|
      # find dummy apps matching orm, and for each
      apps_matching(orm).each do |name|    
        configure the dummy app for that orm
        engine_config.get_dummy(name).configure!
      end
    end
  end

  protected

    attr_accessor :args, :engine_config

    include Mengine::Base

    def create_engine_config
      self.engine_config = Mengine::EngineConfig.new root_path, test_type
    end

    # used from inside template
    def application_definition
      engine_config.application_definition
    end
  
    def app_args
      args = [dummy_app.path] # skip test unit
      args << "-T" if skip_testunit?
      args << "-J" if skip_javascript?      
      # skip active record is orm is set to another datastore      
      args << "-O" if !active_record?
      args
    end

    # rails new command to be executed to generate dummy app
    def command args
      "rails new #{args.join(' ')} -f" # force overwrite
    end

    def sandbox_generator
      Dummy::Sandbox
    end
    
    def install_generator
      Dummy::Install
    end      

    def mongoid_configurator     
      Mengine::Orm::MongoidConfig
    end      

    def orms
      @orms ||= !options[:orms].empty? ? options[:orms] : ['active_record']
    end

    def types
      @types ||= !options[:types].empty? ? options[:types] : [""]
    end

    def root_path 
      File.dirname(__FILE__)
    end

    def test_helper_path
      File.join(root_path, 'test_helpers', test_type).gsub /.+\/\//, ''
    end

    def test_type
      rspec? ? "spec" : "test"
    end
    alias_method :test_path, :test_type

    def skip_testunit?
      options[:tu]
    end

    def skip_javascript?
      options[:js]
    end

    def rspec?
      options[:test_framework] == "rspec"
    end

    def test_unit?
      options[:test_framework] == "test_unit"
    end

    def self.banner
      self_task.formatted_usage(self, false)
    end

    # Cache accessors since we are changing the directory
    def set_accessors!
      self.name
      self.class.source_root
    end

    def name
      @name ||= File.basename(destination_root)
    end

    def camelized
      @camelized ||= underscored.camelize
    end

    def underscored
      @underscored ||= name.underscore
    end
end
