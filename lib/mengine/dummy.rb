module Mengine
  class Dummy  
    attr_accessor :dummy_spec, :dummy_app
    
    def initialize dummy_app
      @dummy_spec = DummySpec.new dummy_app.name
      @dummy_app = dummy_app      
    end        

    def self.create engine_config, app_name, orm, option_args
      self.new DummyApp.new(engine_config, app_name, orm, option_args)
    end

    def argumentor
      dummy_app.argumentor
    end

    def sandbox
      dummy_app.sandbox
    end

    def engine_app
      dummy_app.engine_app
    end
    
    def orm 
      dummy_app.orm
    end
  end
end
