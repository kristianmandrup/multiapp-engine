module Mengine
  class DummySpec
    attr_accessor :name
    
    def initialize name
      @name = name
    end
    
    def named_dir dir_name
      File.join(app_dir, dir_name)
    end

    def app_dir
      File.join app_specs_dir, dummy_app_name
    end

    def app_specs_dir
      "app-specs"
    end
        
    extend self
  end
end