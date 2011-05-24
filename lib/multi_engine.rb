require "thor/group"
require "active_support"
require "active_support/version"
require "active_support/core_ext/string"

require "rails/generators"
require "rails/generators/rails/app/app_generator"

require "sugar-high/file"
require 'fileutils'

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

  argument :path, :type => :string,
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
        self.current_orm = translate(orm) 
        
        say "Creating #{type} dummy Rails app with #{orm_name}", :green
        # say "Location: #{dummy_app_path}"
        command = "rails new #{app_args.join(' ')} -f" # force overwrite
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

        ensure_app_class_name
        
        FileUtils.cd(destination_root)
      end
    end
  end

  protected

    attr_accessor :current_orm, :current_type

    def ensure_app_class_name
      File.replace_content_from application_file, :where => /Dummy\S+/, :with => dummy_app_class_name      
    end

    def orm_name
      translate current_orm
    end

    def translate orm
      case orm.to_sym
      when :ar
        'active_record'
      else
        orm
      end
    end

    def dummy_app_path
      dummy_path
    end

    def dummy_app_name
      name = "dummy"
      name << "-#{current_type}" if current_type && !current_type.blank?
      name << "-#{current_orm}"
      name
    end

    def dummy_path
      "#{test_path}/dummy-apps/#{dummy_app_name}"
    end

    def orms
      @orms ||= !options[:orms].empty? ? options[:orms] : ['active_record']
    end

    def types
      @types ||= !options[:types].empty? ? options[:types] : [""]
    end

    def set_orm_helpers
      # say "Configuring testing files for #{current_orm} app"
      inside test_path do                
        unless File.directory? dummy_app_integration_test_dir
          empty_directory dummy_app_integration_test_dir
        end

        copy_orm_helper

        if File.exist?(navigation_file) || File.exist?(dummy_file)
          # say "Copying test files into /#{dummy_app_name}"
          copy_test_files navigation_file, dummy_file          
          inside app_specs_dummy_dir do
            # say "Inside #{app_specs_dummy_dir}"
            replace_orm_in navigation_file
            replace_orm_in dummy_file
          end
        end
      end
    end

    def copy_orm_helper
      file = "#{current_orm}_helper.rb"
      target_file = "#{app_specs_dummy_dir}/#{file}"
      # say "From #{test_helper_path} copy"
      FileUtils.cp("#{test_helper_path}/orm/#{file}", target_file)
      File.replace_content_from target_file, :where => '#dummy_app_name#', :with => dummy_app_name      
    end

    def test_helper_path
      File.join(File.dirname(__FILE__), 'test_helpers', test_path).gsub /.+\/\//, ''
    end

    def app_specs_dummy_dir
      "app_specs/#{dummy_app_name}"
    end

    def dummy_app_integration_test_dir
      "#{app_specs_dummy_dir}/integration"
    end

    def copy_test_files *files
      files.each do |file| 
        target_file = "#{app_specs_dummy_dir}/#{file}"
        src_file = File.join(test_helper_path, file)
        # say "Copy #{file} to #{target_file}"       
        FileUtils.cp(src_file, target_file) if File.exist?(file)
      end
    end

    def replace_orm_in file
      return if !File.exist?(file)
      # say "Replacing #orm# with #{current_orm} inside #{file}"
      File.replace_content_from file, :where => '#orm#', :with => current_orm
      File.replace_content_from file, :where => '#path#', :with => app_specs_dummy_dir
      File.replace_content_from file, :where => '#camelized#', :with => dummy_app_class_name      
    end

    def navigation_file
      "integration/navigation_#{test_ext}.rb"
    end

    def dummy_file
      "dummy_#{test_ext}.rb"
    end

    def dummy_app_test_path
      File.join(dummy_app_path, test_path)
    end

    def orm_config_method
      "config_#{current_orm}"
    end

    def config_mongoid
      return if !current_orm == 'mongoid'

      say "Configuring app for #{current_orm}"
      inside dummy_app_path do
        gemfile = 'Gemfile'

#         File.insert_into gemfile, :after => 'gem "sqlite3"' do 
#          %q{gem "mongoid"
# gem "bson_ext"
# }
#         end

        append_to_file gemfile do 
         %q{gem "mongoid"
gem "bson_ext"
}
        end        
        File.remove_content_from gemfile, :where => 'gem "sqlite3"'
        
        if File.exist? 'config/database.yml'
          # say "Delete database.yml"
          File.delete! 'config/database.yml'
        end

        # say "Remove active record from #{application_file}"
        File.remove_content_from 'config/application.rb', :where => 'require "active_record/railtie"'
        
        exec_command 'bundle install'
        exec_command 'rails g mongoid:config'
      end
    end

    def exec_command command
      Kernel::system command
    end

    def remove_uneeded_rails_files
      inside dummy_app_path do
        remove_file ".gitignore"
        # remove_file "db/seeds.rb"
        remove_file "doc"
        # remove_file "Gemfile"
        remove_file "lib/tasks"
        remove_file "public/images/rails.png"
        remove_file "public/index.html"
        remove_file "public/robots.txt"
        remove_file "README"
        remove_file "test"
        remove_file "vendor"
      end
    end

    def change_config_files
      store_application_definition!
      template "rails/boot.rb", "#{dummy_app_path}/config/boot.rb", :force => true
      template "rails/application.rb", "#{dummy_app_path}/config/application.rb", :force => true
    end
  
    def app_args
      args = [dummy_app_path] # skip test unit
      args << "-T" if skip_testunit?
      args << "-J" if skip_javascript?      
      # skip active record is orm is set to another datastore      
      args << "-O" if !active_record?
      args
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

    def test_path
      rspec? ? "spec" : "test"
    end
    alias_method :test_ext, :test_path

    def self.banner
      self_task.formatted_usage(self, false)
    end

    def application_definition
      contents = File.read(config_app_file)
      index = (contents.index("module #{dummy_app_class_name}")) || 0        
      contents[index..-1]
    end
    alias :store_application_definition! :application_definition

    def dummy_app_class_name
      dummy_app_name.underscore.camelize
    end

    def config_app_file 
      File.expand_path(application_file, destination_root)
    end
    
    def application_file
      "#{dummy_app_path}/config/application.rb"
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
