module Mengine
  class Orm
    autoload :MongoidConfig, 'mengine/orm/mongoid_config'
    
    attr_accessor :orm
    
    def initialize orm
      @orm = orm
    end
    
    module Helper
      def orm_config_method
        "config_#{orm}"
      end

      def replace_orm_in file
        return if !File.exist?(file)
        [['orm', orm], ['path', app_specs_dummy_dir], ['camelized', dummy_app_class_name]].each do |pair|
          replace_content file, pair[0], pair[1]
        end
      end

      def replace_content file, where, content
        File.replace_content_from file, :where => "##{where}#", :with => content
      end

      def copy_orm_helper
        FileUtils.cp src_file, target_file
        File.replace_content_from target_file, :where => '#dummy_app_name#', :with => dummy_app_name      
      end

      def src_file
        @src ||= File.join test_helper_path, 'orm', orm_helper
      end
        
      def target_file
        @tf ||= File.join app_specs_dummy_dir, orm_helper
      end

      def orm_helper
        "#{orm}_helper.rb"
      end

      def set_orm_helpers
        # say "Configuring testing files for #{current_orm} app"
        inside test_path do                
          empty_directory(dummy_app_integration_test_dir) unless File.directory?(dummy_app_integration_test_dir)
          copy_orm_helper
          copy_tests
        end
      end

      def copy_tests
        if File.exist?(navigation_file) || File.exist?(dummy_file)
          # say "Copying test files into /#{dummy_app_name}"
          copy_test_files navigation_file, dummy_file
          replace_orm_in navigation_file, dummy_file
        end
      end

      def replace_orm_in_files *files
        inside app_specs_dummy_dir do
          files.each do {|file| replace_orm_in file}
        end
      end

      def orm_name
        translate current_orm
      end

      def translate orm
        case orm.to_sym
        when :ar
          'active_record'
        else
          orm
        end
      end
    end
  end
end