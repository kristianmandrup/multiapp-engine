module Mengine
  class DummyApp 
    include Thor::Actions # enable invoke and template actions etc.

    def self.source_root
      @_source_root ||= File.expand_path('../../templates', __FILE__)
    end
    
    attr_accessor :root, :type, :orm, :option_args, :test_type

    def initialize root, test_type, type, orm, option_args
      @root = root
      @type = type
      @orm = orm            
      @test_type = test_type
      @option_args = option_args
    end
    
    def name
      @name ||= begin
        arr = [dummy_prefix]
        arr << type if type && !type.blank?
        arr << orm
        arr.join('-')
      end
    end     

    def create_args
      cargs = ["--command \"#{args_string}\" -t #{test_type}"]
    end
    
    # the path to the dummy app 
    # - fx spec/dummy-apps/dummy-mongoid
    def path    
      File.join(dummy_apps_path, name)
    end
    alias_method :full_name, :path        

    def dummy_apps_path 
      File.join(test_type, apps_dir_name)
    end

    def orm_name
      case orm.to_sym
      when :ar
        'active_record'
      else
        orm
      end      
    end

    # rails new command to be executed to generate dummy app
    
    def ensure_class_name
      File.replace_content_from application_file, :where => /Dummy\S+/, :with => class_name      
    end

    def args 
      [path] + option_args
    end

    def args_string 
      args.join(' ')
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
    
    def apps_dir_name
      "dummy-apps"
    end

    def dummy_prefix
      "dummy"
    end    
  end
end
