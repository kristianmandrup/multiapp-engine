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

  class DummyApp 
    attr_accessor :root, :type, :orm

    def initialize root, type, orm
      @root = root
      @type = type
      @orm = orm            
    end
    
    def name
      @name = begin
        arr = [dummy_prefix]
        arr << type if type && !type.blank?
        arr << orm
        arr.join('-')
      end
    end
    
    def ensure_class_name
      File.replace_content_from application_file, :where => /Dummy\S+/, :with => class_name      
    end
    
    # class name of the dummy app
    # - fx DummyMongoid
    def class_name
      name.underscore.camelize      
    end

    # the full path to the dummy app dir
    # - fx /.../myengine/spec/dummy-apps/dummy-mongoid/config/application.rb
    def full_app_path 
      File.expand_path(application_file, root)
    end
    
    def config_path
      File.join app_path, 'config'
    end

    # the path to the application file of a dummy app 
    # - fx spec/dummy-apps/dummy-mongoid/config/application.rb
    def application_file
      config_file 'application.rb'
    end

    def boot_file
      config_file 'boot.rb'
    end

    def config_file name
      File.join config_path, name

    # the path to the dummy app 
    # - fx spec/dummy-apps/dummy-mongoid
    def app_path    
      File.join(test_type, apps_dir_name, dummy_app_name)
    end        

    def test_path
      File.join(app_path, test_type)
    end    

    def test_type
      rspec? ? "spec" : "test"
    end

    def apps_dir_name
      "dummy-apps"
    end

    def dummy_prefix
      "dummy"
    end
    
    extend self
  end
end
