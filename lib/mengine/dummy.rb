module Mengine
  class Dummy
    include Thor::Actions # enable invoke

    def self.source_root
      @_source_root ||= File.expand_path('../../templates', __FILE__)
    end
  
    attr_accessor :dummy_spec, :dummy_app, :engine_config
    
    def initialize dummy_app
      @dummy_spec = DummySpec.new dummy_app.name
      @dummy_app = dummy_app      
    end        
    
    def create root_path, type, orm
      DummyApp.new root_path, type, orm
    end      

    def orm 
      dummy_app.orm
    end

    def configure
      configure_orm
      install_gems
    end      
          
    def install_gems
      case orm.to_sym 
      when :mongoid
        # puts gems into Gemfile and runs bundle to install them, then runs install and config generators
        invoke install_generator, ["ALL --gems mongoid bson_ext --orms mongoid"] 
      end
    end
    
    def configure_orm
      case orm.to_sym 
      when :mongoid
        mongoid_configurator.new app_name
      end
      say "Configuring testing framework for #{orm}"      
      Mengine::Orm.new(dummy).set_orm_helpers      
    end        
  end
end
