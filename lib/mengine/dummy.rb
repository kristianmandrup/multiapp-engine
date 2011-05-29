module Mengine
  class Dummy
    include Thor::Actions # enable invoke

    def self.source_root
      @_source_root ||= File.expand_path('../../templates', __FILE__)
    end
  
    attr_accessor :dummy_spec, :dummy_app, :engine_config
    
    def initialize dummy_app
      @dummy_spec = DummySpec.new dummy_app.name
      @dummy_app = dummy_app      
    end        
    
    def orm 
      dummy_app.orm
    end
  end
end
