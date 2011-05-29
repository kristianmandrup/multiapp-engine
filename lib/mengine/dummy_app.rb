module Mengine
  class DummyApp 
    include Thor::Actions # enable invoke and template actions etc.

    def self.source_root
      @_source_root ||= File.expand_path('../../templates', __FILE__)
    end
    
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

    # the path to the dummy app 
    # - fx spec/dummy-apps/dummy-mongoid
    def path    
      File.join(test_type, apps_dir_name, dummy_app_name)
    end        

    # change config files 'boot' and 'application' of dummy app
    def change_config_files
      template "rails/boot.rb", "#{dummy_app.boot_file}", :force => true
      template "rails/application.rb", "#{dummy_app.application_file}", :force => true
    end

    def remove_uneeded_rails_files
      # "db/seeds.rb", "Gemfile"
      inside path do        
        [".gitignore", "doc", "lib/tasks", "public/images/rails.png", "public/index.html", "public/robots.txt", "README", "test"].each do |file|
          remove_file file
        end
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
      File.join path, 'config'
    end

    # the path to the application file of a dummy app 
    # - fx spec/dummy-apps/dummy-mongoid/config/application.rb
    def application_file
      config_file 'application.rb'
    end

    def boot_file
      config_file 'boot.rb'
    end

    def config_file file
      File.join config_path, file
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
  end
end
