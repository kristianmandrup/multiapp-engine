require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'

require "mengine/base"
require "mengine/apps_matcher"
require "mengine/engine_config"
require "mengine/base"
require "mengine/dummy"
require "mengine/dummy_app"
require "mengine/dummy_spec"
require "mengine/orm"          
require "mengine/templates"  

require "dummy/install"   

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

  class_option :apps, :type => :array, :default => [], 
                                :desc => "Dummy application names"

  class_option :tu,  :type => :boolean, :default => true,
                                :desc => "Skip testunit generation for dummy apps."

  class_option :js,  :type => :boolean, :default => true,
                                :desc => "Skip javascript generation for dummy apps."

  class_option  :sandbox,   :type => :string, :default => "~/rails-dummies", :aliases => "-s",
                              :desc => "Where to sandbox rails dummy apps"

  
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
    say "Vendoring Rails applications in #{test_folder}/#{dummy_container}"

    apps.each do |type| 
      postfix = types.size > 1 ? "apps" : ""
      say "Creating dummy #{type} #{postfix}"
      orms.each do |orm|
        say "ORM #{orm}"

        # set dummy app and add to dummies
        engine_config.create_dummy type, orm, rails_new_option_args(orm)

        # create an empty dummy folder in the test dir      
        create_empty_dummy!
      end
    end
  end
  
  def configure_app_for_orms
    say "Configuring apps for orms"
    # for each orm
    orms.each do |orm|
      say "ORM #{orm}"

      # in engine find dummy apps matching orm, and for each
      matching_apps_for orm do |app_name|
        configure_app! name        
      end
    end
  end

  protected

    attr_reader :active_dummy
    
    include Mengine::Base
    include Mengine::OptionsHelper

    def matching_apps_for orm 
      engine_apps.apps_matcher.apps_matching(orm)
    end

    def configure_app! name
      say "Configuring #{name} app"        
      # create the dummy app for that orm
      self.active_dummy = engine_config.get_dummy(name)
      create_app! if active_dummy
    end
          
    def create_app!
      # run rails new generator
      create_rails_app
      # configure for orm
      configure_orm
    end      

    # CREATE RAILS APP

    def create_rails_app
      run_dummy_generator :create, create_gen_arguments
    end
             
    def create_gen_arguments
      dummy_app.argumentor.generator_arguments_for :create
    end
    
    # CONFIGURE ORM

    def configure_orm
      run_dummy_generator :ormconf, ormconf_gen_arguments
    end

    def ormconf_gen_arguments
      active_dummy.argumentor.generator_arguments_for :ormconf
    end

    # FILE HELPERS

    # create empty dummy dir
    def create_empty_dummy!   
      make_empty_dir(sandbox.dummy_path)
    end

    def make_empty_dir dir
      empty_directory(dir) unless File.directory?(dir)
    end
  
    def rails_new_option_args(orm)
      args = []
      args << "-T" if skip_testunit?
      args << "-J" if skip_javascript?      
      # skip active record is orm is set to another datastore      
      args << "-O" if !active_record?(orm)
      args
    end
    
    def mengine_root_path
      File.expand_path('../', __FILE__)
    end

    def active_record? orm
      ['active_record', 'ar'].include?(orm)
    end

    def dummy_container
      Mengine::EngineApps.dummy_apps_container
    end
    
    def sandbox
      dummy_app.sandbox
    end

    def dummy_app
      active_dummy.dummy_app
    end  
    
    def skip_testunit?
      options[:tu]
    end

    def skip_javascript?
      options[:js]
    end

    def self.banner
      self_task.formatted_usage(self, false)
    end

    # OPTIONS

    # Cache accessors since we are changing the directory
    def set_accessors!
      self.engine_name
      self.class.source_root
    end

    def engine_name
      @engine_name ||= File.basename(destination_root)
    end

    def camelized
      @camelized ||= underscored.camelize
    end

    def underscored
      @underscored ||= engine_name.underscore
    end      
end
