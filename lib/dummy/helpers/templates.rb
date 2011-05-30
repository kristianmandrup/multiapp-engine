module Dummy
  module Helpers
    class Templates
      attr_reader :mengine, :dummy
    
      def initialize mengine, dummy
        @mengine = mengine
        @dummy = dummy
      end
    
      def copy_test_files *files
        files.each do |file| 
          FileUtils.cp src_file(file), target_file(file) if File.exist?(src_file(file))
        end
      end

      protected

      def tests_path 
        test_dir
      end
    
      def mengine_root_path
        mengine.root_path
      end

      def engine_config
        mengine.engine_config
      end

      def dummy_spec
        dummy.dummy_spec
      end

      def test_helper_path
        mengine.test_helper_path
      end

      def target_file file
        File.join dummy_spec.app_spec_dir, file
      end 
    
      def src_file 
        File.join test_helper_path, file
      end

      def navigation_file
        "integration/navigation_#{test_dir}.rb"
      end

      def dummy_file
        "dummy_#{test_dir}.rb"
      end
    end
  end
end