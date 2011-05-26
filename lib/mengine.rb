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
        
        dummy_app = DummyApp.new root_path, type, orm
        self.args = app_args(dummy_app)
        
        say "Creating #{type} dummy Rails app with #{orm_name}", :green        
        say command
        exec_command command

        #invoke Rails::Generators::AppGenerator, app_args

        say "Configuring Rails app"
        change_config_files

        # say "Removing unneeded files"
        remove_uneeded_rails_files
            
        send orm_config_method if respond_to?(orm_config_method)

        say "Configuring testing framework for #{orm_name}"      
        set_orm_helpers

        dummy_app.ensure_class_name
        
        FileUtils.cd(destination_root)
      end
    end
  end

  protected

    attr_accessor :args

    include Mengine
    include Mengine::Orm

    def command args
      "rails new #{args.join(' ')} -f" # force overwrite
    end

    def orms
      @orms ||= !options[:orms].empty? ? options[:orms] : ['active_record']
    end

    def types
      @types ||= !options[:types].empty? ? options[:types] : [""]
    end

    def remove_uneeded_rails_files
      # "db/seeds.rb", "Gemfile"
      inside dummy_app_path do        
        [".gitignore", "doc", "lib/tasks", "public/images/rails.png", "public/index.html", "public/robots.txt", "README", "test"].each do |file|
          remove_file file
        end
      end
    end

    def change_config_files
      store_application_definition!
      template "rails/boot.rb", "#{DummyApp.boot_file}", :force => true
      template "rails/application.rb", "#{DummyApp.application_file}", :force => true
    end

    def application_definition
      contents = File.read(DummyApp.application_file)
      index = (contents.index("module #{DummyApp.class_name}")) || 0        
      contents[index..-1]
    end
    alias :store_application_definition! :application_definition
  
    def app_args dummy_app
      args = [dummy_app.app_path] # skip test unit
      args << "-T" if skip_testunit?
      args << "-J" if skip_javascript?      
      # skip active record is orm is set to another datastore      
      args << "-O" if !active_record?
      args
    end

    def root_path 
      File.dirname(__FILE__)
    end

    def test_helper_path
      File.join(root_path, 'test_helpers', DummyApp.test_path).gsub /.+\/\//, ''
    end

    def active_record?
      !current_orm || ['active_record', 'ar'].include?(current_orm)
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
