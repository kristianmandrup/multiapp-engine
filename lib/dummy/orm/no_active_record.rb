module Dummy
  module Orm
    class NoActiveRecord
      attr_accessor :dummy
      
      def initialize dummy
        @dummy = dummy
      end
      
      # This should NOT be necessary, but should be handled by mongoid:config 
      def remove_default_ar_config
        remove_app_ar_config
        remove_default_db_config
      end

      # This should NOT be necessary, but should be handled by mongoid:config 
      def remove_app_ar_config
        File.remove_content_from application_file, :where => 'require "active_record/railtie"'
      end

      # This should NOT be necessary, but should be handled by mongoid:config       
      def remove_default_db_config
        File.delete! db_file if File.exist?(db_file)
      end
      
      protected

      def dummy_app
        dummy.dummy_app
      end
      
      def application_file
        File.join(config_path, 'application.rb')
      end

      def db_file
        File.join(config_path, 'database.yml')
      end

      def config_path
        File.join(sandbox_dummy, 'config')
      end 
      
      def sandbox_dummy
        sandbox.dummy_path(dummy_app.name)
      end      
    end
  end
end