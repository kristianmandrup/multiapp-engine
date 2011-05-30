module Mengine
  class Sandbox
    attr_reader :root_path, :options
    
    def initialize root_path, options = {}
      @root_path = root_path
      @options = options
    end

    def orms 
      options[:orms]
    end

    def apps     
      options[:apps]
    end
    
    def apps_matcher
      @apps_matcher ||= Mengine::AppsMatcher.new root_path, :orms => orms, :apps => apps
    end
  end
end