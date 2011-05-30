module Mengine
  class DummySpec
    attr_reader :name # name of dummy app
    attr_reader :engine_config

    # initialized with the name of the dummy app
    def initialize engine_config, name
      @engine_config = engine_config
      @name = name
    end

    def app_spec_dir
      File.join app_specs_dir, name
    end

    def create_integration_spec_folder
      make_empty_dir(spec_integration_dir)
    end

    def spec_integration_dir
      sub_dir 'integration'
    end
    
    def make_empty_dir dir_name
      FileUtils.mkdir_p(dir_name) if !File.directory? dir_name
    end    
    
    def test_framework
      engine_config.test_framework
    end      
    
    def sub_dir dir_name
      File.join(app_spec_dir, dir_name)
    end    

    def app_specs_path
      File.join tests_folder, app_specs_folder_name
    end

    def tests_folder
      engine_config.engine_apps.tests_folder
    end
    
    def app_specs_folder_name
      "app-specs"
    end            
  end
end