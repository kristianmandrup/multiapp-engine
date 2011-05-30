require 'sugar-high/file_mutate'

module Dummy
  module Orms
    class BaseInstaller
      attr_reader :dummy
      
      def initialize dummy
        @dummy = dummy
      end

      def install!
        say "Installing #{orm} for app #{app_name}"
        
        # inside the         
        File.append gemfile_path, :content => gem_statements
          end        
          File.remove_content_from gemfile_path, :where => 'gem "sqlite3"'
        end
      end            
      
      protected

      def gemfile_path
        @gemfile_path ||= File.join(sandbox.dummy_path(app_name), gemfile)
      end

      def gemfile
        'Gemfile'
      end

      def app_name
        dummy.dummy_app.name
      end

      def orm
        dummy.orm
      end
      
      def sandbox
        dummy.sandbox
      end      
    end
  end
end