module Mengine
  class EngineApps
    attr_reader :root_path, :test_folder, :options
    
    def initialize root_path, test_folder, options = {}
      @root_path = root_path
      @test_folder = test_folder
      @options = options
    end

    def orms 
      options[:orms]
    end

    def apps     
      options[:apps]
    end

    # the container folder of dummy apps in the engine created
    def dummy_apps_container_path
      File.join tests_path, dummy_apps_container
    end

    def tests_path
      File.join root_path, test_folder
    end

    def dummy_apps_container
      self.class.dummy_apps_container
    end

    def self.dummy_apps_container
      "dummy-apps"
    end
    
    def apps_matcher
      @apps_matcher ||= Mengine::AppsMatcher.new dummy_apps_container_path, :orms => orms, :apps => apps
    end
  end
end

