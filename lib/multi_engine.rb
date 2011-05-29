require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'

require "mengine/base"
require "mengine/engine_config"
require "mengine/base"
require "mengine/dummy"
require "mengine/dummy_app"
require "mengine/dummy_spec"
require "mengine/orm"          
require "mengine/templates"      

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

    # Remove use of FileUtils explicitly - instead include SugarHigh module with file DSL :)
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
      orms.each do |orm|

        # set dummy app and add to dummies
        engine_config.create_dummy type, orm, app_args(orm)

        # create an empty dummy folder in the test dir      
        create_empty_dummy!
        
         
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
        # configure the dummy app for that orm
        engine_config.get_dummy(name).configure!
      end
    end
  end

  protected

    attr_accessor :engine_config

    include Mengine::Base

    def create_engine_config
      self.engine_config = Mengine::EngineConfig.new destination_root, test_type
    end

    # create empty dummy dir
    def create_empty_dummy!
      make_empty_dir(dummy_app.path)
    end

    # used from inside template
    def application_definition
      engine_config.application_definition
    end

    def dummy_app
      engine_config.dummy_app
    end
  
    def app_args(orm)
      args = []
      args << "-T" if skip_testunit?
      args << "-J" if skip_javascript?      
      # skip active record is orm is set to another datastore      
      args << "-O" if !active_record?(orm)
      args
    end
    
    def install_generator
      Dummy::Install
    end      

    def mongoid_configurator     
      Mengine::Orm::MongoidConfig
    end      

    def make_empty_dir name
      empty_directory(name) unless File.directory?(name)
    end

    def orms
      @orms ||= !options[:orms].empty? ? options[:orms] : ['active_record']
    end

    def types
      @types ||= !options[:types].empty? ? options[:types] : [""]
    end

    def mengine_root_path 
      File.dirname(__FILE__)
    end

    def test_helper_path
      File.join(root_path, 'test_helpers', test_type).gsub /.+\/\//, ''
    end

    def active_record? orm
      ['active_record', 'ar'].include?(orm)
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
