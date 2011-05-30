require 'mengine/templates'

module Dummy
  module Orm
    class TestTransfer
      attr_reader :engine_config
      
      def initialize engine_config
        @engine_config = engine_config
      end
      
      def copy_tests
        test_files.each {|file| handle_test_file(file)}
      end

      def test_files
        [navigation_file, dummy_file]
      end

      def handle_test_file file
        return if File.exist?(file)
        copy_test_file file
        replace_orm_in file
      end

      def templates
        @templates ||= Mengine::Templates.new root_path, dummy
      end

      def copy_test_files *files
        templates.copy_test_files(*files)
      end   
      
      def navigation_file
        templates.navigation_file
      end

      def dummy_file
        templates.dummy_file
      end      
    end
  end
end