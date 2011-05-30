module Dummy
  module Orm
    module Mongoid
      def config_mongoid
        say "Configuring app for mongoid"

        inside dummy_app.path do
          append_to_file gemfile do 
         %q{gem "mongoid"
  gem "bson_ext"
  }
          end        
          File.remove_content_from gemfile, :where => 'gem "sqlite3"'

          # should use install generator
          exec_command 'bundle install'
          exec_command 'rails g mongoid:config'
        end
      end            
    end
  end
end