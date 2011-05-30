require 'dummy/sandbox'
require 'mengine/base'
require 'mengine/options_helper'

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
      # TODO: export apps to sandbox
      
      # find matching apps in sandbox
      matching_apps.each do |app|        
        create_dummy(app)
        configure_orm
      end
      
      # TODO: import apps to sandbox              
    end

    protected

    attr_accessor :name

    include Mengine::Base
    include Dummy::Gems::Helper
    include Dummy::Orm::Gems
    include Mengine::OptionsHelper

    def mengine
      @mengine ||= Mengine::Config.new File.expand_path('../../', __FILE__), engine_config
    end
    
    def create_dummy app_name
      engine_config.create_dummy app_name, orm      
    end

    def active_dummy 
      engine_config.active_dummy
    end

    def orm_configurator
      @orm_configurator ||= Mengine::Orm::Configurator.new destination_path, active_dummy
    end

    def configure_orm
      say "Configuring testing framework for #{orm}"
      orm_configurator.configure_orm_helpers!      
    end        

    def orm
      translate options[:orm]
    end

    def sandbox
      dummy_app.sandbox
    end

    def dummy_app
      active_dummy.dummy_app
    end  
  end     
end
