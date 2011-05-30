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
      
      def application_file
        File.join(sandbox_dummy_config_path, 'application.rb')
      end

      def db_file
        File.join(sandbox_dummy_config_path, 'database.yml')
      end

      def sandbox_dummy_config_path
        File.join(dummy_app.sandbox_path, 'config')
      end 
    end
  end
end