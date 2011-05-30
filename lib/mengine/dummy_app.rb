# require 'active_support/inflector'
require 'mengine/base'
require 'mengine/dummy_app/sandbox'
require 'mengine/dummy_app/engine_app'
require 'mengine/dummy_app/argumentor'

module Mengine
  class DummyApp 
    include Mengine::Base
    
    attr_reader :engine_config, :app_name, :option_args
    attr_reader  :sandbox, :engine_app, :argumentor

    def initialize engine_config, app_name, orm, option_args
      @engine_config = engine_config

      @app_name = app_name
      @orm = orm                  
      @option_args = option_args

      @sandbox = Sandbox.new engine_config, self
      @engine_app = EngineApp.new engine_config, self 
      @argumentor = Argumentor.new self
    end
    
    def name
      @name ||= begin
        arr = [dummy_prefix]
        arr << app_name ifapp_name && !app_name.blank?
        arr << orm
        arr.join('-')
      end
    end     

    def class_name
      name.camelize
    end

    def test_framework
      engine_config.test_framework
    end
    
    def orm
      translate @orm
    end
        
    def dummy_prefix
      "dummy"
    end    
  end
end
