module Dummy
  module Orm
    class Replacer
      attr_reader :dummy, :mengine
      
      def initialize mengine, dummy
        @mengine = mengine
        @dummy = dummy
      end

      # the orm_helper.rb is put in the root of the dummy app spec folder 
      def copy_orm_helper
        FileUtils.cp src_file, target_file
        replace_content target_file, 'dummy_app_name', dummy_app.name
      end

      def replace_orm_in_files *files
        inside dummy_spec.path do
          files.each {|file| replace_orm_in file}
        end
      end
      
      def replace_orm_in file
        return if !File.exist?(file)
        [['orm', orm], ['path', dummy_spec.application_file], ['camelized', dummy_app.class_name]].each do |pair|
          replace_content file, pair[0], pair[1]
        end
      end

      protected

      def replace_content file, where, content
        File.replace_content_from file, :where => "##{where}#", :with => content
      end

      # the orm_helper.rb file in the right /test_helpers subdirectory (for rspec or test unit)
      def src_file
        @src ||= File.join test_helper_path, 'orm', orm_helper
      end

      # the orm_helper.rb is put in the root of the dummy app spec folder 
      def target_file
        @tf ||= File.join dummy_spec.app_path, orm_helper
      end

      def orm_helper
        "#{orm}_helper.rb"
      end

      def test_helper_path
        mengine.test_helper_path
      end
      
      def dummy_spec
        dummy.dummy_spec
      end
    end
  end
end