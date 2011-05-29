module Mengine
  class DummySpec
    attr_accessor :name # name of dummy app

    # initialized with the name of the dummy app
    def initialize name
      @name = name
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