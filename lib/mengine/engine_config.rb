require 'dummy/sandbox'
require 'mengine/base'

# The main configuration of the engine to be built
module Mengine #< Thor::Group
  class EngineConfig 
    
    attr_accessor :root_path, :test_type

    attr_accessor :dummies, :dummy
    
    def initialize root_path, test_type
      @root_path = root_path
      @test_type = test_type      
      @dummies = {}      
    end        

    def get_dummy name
      dummies[short_name(name)]
    end

    def get_dummy_app name
      get_dummy(name).dummy_app
    end
    
    # set current dummy app and also add it to list of dummies for later iteration 
    def create_dummy type, orm, args = []
      dum_app = DummyApp.new root_path, test_type, type, orm, args
      self.dummy = Dummy.new dum_app      
      dummies[dummy_app.name] = dummy
    end
    
    # used from inside template
    def application_definition
      contents = File.read(dummy_app.application_file)
      index = (contents.index("module #{dummy_app.class_name}")) || 0        
      contents[index..-1]
    end

    def short_name name
      name.gsub /.+\/(.+)$/, '\1'
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
