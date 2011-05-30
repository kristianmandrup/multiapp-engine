module Mengine
  class DummySpec
    attr_reader :name # name of dummy app
    attr_reader :engine_config

    # initialized with the name of the dummy app
    def initialize engine_config, name
      @engine_config = engine_config
      @name = name
    end

    def test_framework
      engine_config.test_framework
    end      
    
    def named_dir dir_name
      File.join(app_dir, dir_name)
    end

    def app_dir
      File.join app_specs_dir, name
    end

    def app_specs_dir
      "app-specs"
    end        
  end
end