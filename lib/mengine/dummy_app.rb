require 'active_support/inflector'
require 'mengine/base'

module Mengine
  class DummyApp 
    include Mengine::Base
    
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

    # name of dummy app
    # full rails new command options
    # testing dir (spec or test)
    def create_args
      args = []
      args << make_arg(:apps, name)
      args << make_arg(:opts, args_string, true)
      # args << make_arg(:test_framework, test_type)
      args
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
    
    def args_string 
      option_args.join(' ')
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
