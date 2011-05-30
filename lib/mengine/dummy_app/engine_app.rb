module Mengine
  class DummyApp 
    class EngineApp
      include Mengine::DummyApp::Base
      
      attr_accessor :dummy_app, :engine_config

      def initialize engine_config, dummy_app
        @engine_config = engine_config
        @dummy_app = dummy_app
      end

      # used from inside template
      def application_definition
        contents = File.read(application_file)
        index = (contents.index("module #{class_name}")) || 0        
        contents[index..-1]
      end

      def name
        dummy_app.name
      end            

      def engine_apps
        engine_config.engine_apps
      end

      def container_path
        engine_apps.dummy_apps_container_path
      end            

      def test_framework
        dummy_app.test_framework
      end
    end
  end
end

