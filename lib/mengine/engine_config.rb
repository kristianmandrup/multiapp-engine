require 'dummy/sandbox'
require 'mengine/base'

# The main configuration of the engine to be built
module Mengine #< Thor::Group
  class EngineConfig 
    
    attr_reader :root_path, :test_framework, :sandbox, :engine_apps
    attr_reader :dummies,   :active_dummy
    
    def initialize root_path, test_framework, sandbox, engine_apps
      @root_path = root_path
      @test_framework = test_framework      
      @sandbox = sandbox
      @engine_apps = engine_apps 
      @dummies = {}      
    end        

    def get_dummy name
      dummies[short_name(name)]
    end

    def get_dummy_app name
      get_dummy(name).dummy_app
    end
    
    # set current dummy app and also add it to list of dummies for later iteration 
    def create_dummy type, orm, option_args = []
      @active_dummy = Dummy.create self, type, orm, option_args
      dummies[dummy_app.name] = @active_dummy
    end
    
    def dummy_app
      dummy.dummy_app
    end 
    
    def dummy_spec
      dummy.dummy_spec
    end 
    
    include Mengine::Base       
  end
end
