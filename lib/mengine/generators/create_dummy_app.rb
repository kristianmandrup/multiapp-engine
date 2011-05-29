require 'dummy/sandbox'

module Mengine
  module Generators
    class CreateDummyApp < Thor::Group  
      include Thor::Actions
      check_unknown_options!

      def self.source_root
        @_source_root ||= File.expand_path('../../../templates', __FILE__)
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

      argument      :name,     :desc => "Name of dummy app"

      class_option  :command_options, :desc => "Rails new command options"

      class_option  :test_framework,  :default => "rspec", :aliases => "-t",
                                    :desc => "Test framework to use. test_unit or rspec."

      def execute!
        # export empty dummy app to sandbox
        # execute rails new command (in force mode)
        # import dummy app back in
        say "Creating rails app in sandbox: #{args}"

        invoke sandbox_generator, args # , "-b"

        say "Configuring Rails app"
        # configure dummy app
        change_config_files
        # ensure dummy app class name is right
        ensure_class_name
      end

      protected

      def args
        [name, "--command '#{rails_new_command}'"]
      end

      def rails_new_command
        "rails new #{name} #{command_options} -f" # force overwrite
      end

      def sandbox_generator
        ::Dummy::Sandbox
      end

      # change config files 'boot' and 'application' of dummy app
      def change_config_files
        template "rails/boot.rb", "#{boot_file}", :force => true
        template "rails/application.rb", "#{application_file}", :force => true
      end

      def remove_uneeded_rails_files
        # "db/seeds.rb", "Gemfile", ".gitignore"
        inside path do        
          ["doc", "README", "lib/tasks", "public/images/rails.png", "public/index.html", "public/robots.txt", "test"].each do |file|
            remove_file file
          end
        end
      end

      def command_options
        options[:command]
      end

      # the path to the dummy app 
      # - fx spec/dummy-apps/dummy-mongoid
      def path    
        File.join(dummy_apps_path, name)
      end

      def test_type
        options[:test_framework] || 'rspec'
      end

      def dummy_apps_path 
        File.join(test_type, "dummy-apps")
      end
    
      def config_path
        File.join path, 'config'
      end

      # the path to the application file of a dummy app 
      # - fx spec/dummy-apps/dummy-mongoid/config/application.rb
      def application_file
        config_file 'application.rb'
      end

      def boot_file
        config_file 'boot.rb'
      end

      def config_file file
        File.join config_path, file
      end    
    end     
  end
end