module Mengine
  class Orm
    module MongoidConfig      
      def config_mongoid dummy_app
        say "Configuring app for mongoid"

        inside dummy_app.path do
          append_to_file gemfile do 
         %q{gem "mongoid"
gem "bson_ext"
}
          end        
          File.remove_content_from gemfile, :where => 'gem "sqlite3"'
                
          exec_command 'bundle install'
          exec_command 'rails g mongoid:config'
        end
      end

      def gemfile
        'Gemfile'
      end

      # This should NOT be necessary, but should be handled by mongoid:config 
      def remove_default_ar_config
        remove_app_ar_config
        remove_default_db_config
      end
   
      # This should NOT be necessary, but should be handled by mongoid:config 
      def remove_app_ar_config
        File.remove_content_from 'config/application.rb', :where => 'require "active_record/railtie"'
      end

      # This should NOT be necessary, but should be handled by mongoid:config       
      def remove_default_db_config
        File.delete! 'config/database.yml' if File.exist?('config/database.yml')
      end
    end
  end
end