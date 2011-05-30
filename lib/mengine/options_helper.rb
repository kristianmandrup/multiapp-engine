module Mengine
  module OptionsHelper
    def engine_config
      @engine_config ||= Mengine::EngineConfig.create destination_root, sandbox_root_path, test_framework, :orms => orms, :apps => apps
    end    
    
    # the container folder of dummy apps in the sandbox, outside the engine
    def sandbox_root_path
      File.expand_path options[:sandbox]      
    end

    def orms
      @orms ||= !options[:orms].empty? ? options[:orms] : ['active_record']
    end

    def apps
      @apps ||= !options[:apps].empty? ? options[:apps] : [nil]
    end 
    
    def test_framework
      options[:test_framework]
    end

    def test_unit?
      test_framework == "test_unit"
    end
  end
end