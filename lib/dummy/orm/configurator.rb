module Dummy
  module Orm
    class Configurator    
      attr_accessor :dummy, :root_path
    
      def initialize root_path, dummy
        @root_path = root_path      
        @dummy = dummy        
      end

      protected

      include Mengine::Base

      # the orm_helper.rb is put in the root of the dummy app spec folder 
      def copy_orm_helper
        FileUtils.cp src_file, target_file
        replace_content target_file, 'dummy_app_name', dummy_app.name
      end

      def configure_orm_helpers!
        create_integration_spec_folder                
        copy_orm_helper
        copy_tests
        configure_specific_orm
      end

      def include_for_orm              
        case orm.to_sym
        when :mongoid
          require 'dummy/orm/mongoid'
        end
      end

      def configure_specific_orm
        include_for_orm
        remove_default_ar_config
        send orm_config_method(orm) if respond_to? orm_config_method(orm)
      end

      def orm_config_method
        "config_#{orm}"
      end

      def dummy_spec
        dummy.dummy_spec
      end

      def dummy_app
        dummy.dummy_app
      end
    
      def test_folder
        engine_config.test_folder
      end

      def test_helper_path
        File.join(root_path, 'test_helpers', test_folder).gsub /.+\/\//, ''
      end

      def active_record?
        orm.to_sym == :active_record
      end
      
      def orm 
        dummy.orm
      end
      
      def test_framework
        dummy.test_framework 
      end

      def dummy_app 
        dummy.dummy_app
      end      
    end
  end
end