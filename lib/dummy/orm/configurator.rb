module Dummy
  module Orm
    class Configurator    
      attr_reader :dummy, :root_path, :mengine
    
      def initialize mengine, dummy
        @mengine = mengine
        @dummy = dummy        
      end

      def configure_orm_helpers!
        create_integration_spec_folder                
        replacer.copy_orm_helper
        tests_transfer.copy_tests
        configure_specific_orm
      end

      protected

      include Mengine::Base

      def tests_transfer
        TestTransfer.new mengine, dummy
      end

      def replacer
        Replacer.new mengine, dummy
      end

      def include_for_orm              
        case orm.to_sym
        when :mongoid
          require 'dummy/orm/mongoid'
        end
      end

      def configure_specific_orm
        include_for_orm
        ar_remover.remove_default_ar_config
        orm_installer.install! 
      end

      def ar_remover
        @ar_remover ||= NoActiveRecord.new dummy
      end

      def orm_installer
        @orm_installer ||= "#{orm.camelize}Installer".constantize.new dummy
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

      def root_path
        mengine.root_path
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