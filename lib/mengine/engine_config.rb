# The main configuration of the engine to be built
module Mengine
  class EngineConfig
    attr_accessor :root_path, :test_type

    attr_accessor :dummies, :dummy
    
    def initialize root_path, test_type
      @root_path = root_path
      @test_type = test_type      
    end        

    # create empty dummy dir
    def create_empty_dummy
      make_empty_dir(dummy_app.path)
    end

    def get_dummy name
      dummies[name]
    end
    
    # set current dummy app and also add it to list of dummies for later iteration 
    def set_dummy type, orm  
      self.dummy = Dummy.create root_path, type, orm
      self.dummies ||= {}      
      dummies[dummy.name] = dummy
    end
    
    # used from inside template
    def application_definition
      contents = File.read(dummy_app.application_file)
      index = (contents.index("module #{dummy_app.class_name}")) || 0        
      contents[index..-1]
    end

    def dummy_app
      dummy.dummy_app
    end 
    
    def dummy_spec
      dummy.dummy_spec
    end        
  end
end
