require 'dummy/sandbox'

module Dummy
  class OrmConf < Thor::Group  
    include Thor::Actions
    # check_unknown_options!

    def self.source_root
      @_source_root ||= File.expand_path('../../templates', __FILE__)
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

    argument      :apps,            :type => :array, :default => [], :required => false, 
                              :desc => "Names of dummy apps to create"

    class_option  :orm,            :type => :string, 
                              :desc => "ORM to configure dummies for"

    class_option  :test_framework,  :type => :string,  :default => "rspec", :aliases => "-t",
                              :desc => "Test framework to use. test_unit or rspec."

    class_option  :sandbox,         :type => :string, :default => nil, :aliases => "-s",
                              :desc => "Where to sandbox rails dummy apps"

    say "Configures dummy apps for a given ORM"
    def execute!     
      create_orm_configurator

      # TODO: export apps to sandbox
      
      # find matching apps in sandbox
      matching_apps.each do |app|        
        set_dummy create_dummy(app)
        configure_orm
      end
      
      # TODO: import apps to sandbox              
    end

    protected

    attr_accessor :name, :orm_configurator, :dummy

    include Mengine::Base

    def set_dummy dummy
      self.dummy = dummy
      orm_configurator.dummy = dummy
    end

    def create_orm_configurator
      self.orm_configurator = Mengine::Orm::Configurator.new root_path, test_type, orm
    end

    def configure_orm
      say "Configuring testing framework for #{orm}"
      set_orm_helpers
    end        

    def configure_specific_orm
      meth = "config_#{orm}"
      send(meth) if respond_to?(meth)
    end

    def set_orm_helpers conf
      # say "Configuring testing files for #{current_orm} app"
      inside test_path do                
        make_empty_dir(spec_integration_dir)
        copy_orm_helper
        copy_tests
      end
    end

    def install_gems
      case orm.to_sym 
      when :mongoid
        # puts gems into Gemfile and runs bundle to install them, then runs install and config generators
        run_dummy_generator :install, ["ALL --gems mongoid bson_ext --orms mongoid"] 
      end
    end    

    def gemfile
      'Gemfile'
    end

    def sandbox_args(app)
      args = [apps.join(' ')]
      args << make_arg(:command,  rails_new_command(app))
      args
    end

    def sandbox_generator
      ::Dummy::Sandbox
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
  end     
end
