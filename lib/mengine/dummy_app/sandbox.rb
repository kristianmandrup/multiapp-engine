module Mengine
  class DummyApp 
    class Sandbox
      include Mengine::DummyApp::Base
      
      attr_accessor :dummy_app, :container_path
      
      def initialize engine_config, dummy_app
        @container_path = engine_config.sandbox_root_path 
        @dummy_app = dummy_app
      end

      def dummy_path name = nil
        name ? File.join(container_path, name) : container_path
      end

      def name
        dummy_app.name
      end            
    end
  end