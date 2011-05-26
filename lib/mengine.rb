require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'
require "mengine/base"
require "mengine/dummy_app"
require "mengine/orm/helper"

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
    types.each do |type|
      say "Creating #{type} apps"
      self.current_type = type
      orms.each do |orm|
        
        set_dummy type, orm        
        self.args = app_args
        
        say "Creating #{type} dummy Rails app with #{orm_name}", :green        
        say command
        exec_command command

        #invoke Rails::Generators::AppGenerator, app_args

        say "Configuring Rails app"
        change_config_files

        configure_orm(orm)         

        dummy_app.ensure_class_name
        
        FileUtils.cd(destination_root)
      end
    end
  end

  protected

    attr_accessor :args, :dummy

    include Mengine
    include Mengine::Orm

    def set_dummy type, orm
      self.dummy = Dummy.create root_path, type, orm
    end

    def configure_orm orm
      case orm.to_sym 
      when :mongoid
        mongoid_configurator.new root_path, test_type, orm, dummy       
      end
      say "Configuring testing framework for #{orm}"      
      Mengine::Orm.new(root_path, test_type, orm, dummy).set_orm_helpers      
    end

    def change_config_files
      store_application_definition!
      template "rails/boot.rb", "#{dummy_app.boot_file}", :force => true
      template "rails/application.rb", "#{dummy_app.application_file}", :force => true
    end

    def application_definition
      contents = File.read(dummy_app.application_file)
      index = (contents.index("module #{dummy_app.class_name}")) || 0        
      contents[index..-1]
    end
    alias :store_application_definition! :application_definition
  
    def app_args
      args = [dummy_app.app_path] # skip test unit
      args << "-T" if skip_testunit?
      args << "-J" if skip_javascript?      
      # skip active record is orm is set to another datastore      
      args << "-O" if !active_record?
      args
    end

    def mongoid_configurator     
      Mengine::Orm::MongoidConfig
    end      

    def command args
      "rails new #{args.join(' ')} -f" # force overwrite
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

    def dummy_app
      dummy.dummy_app
    end 
    
    def dummy_spec
      dummy.dummy_spec
    end      

    def test_helper_path
      File.join(root_path, 'test_helpers', test_type).gsub /.+\/\//, ''
    end

    def test_type
      rspec? ? "spec" : "test"
    end        

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
