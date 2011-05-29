module Mengine
  class Orm
    autoload :MongoidConfig, 'mengine/orm/mongoid_config'
    
    attr_accessor :orm, :dummy, :root_path, :test_type
    
    def initialize root_path, test_type, orm, dummy
      @orm = orm
      @dummy = dummy
      @test_type = test_type
      @root_path = root_path      
    end

    def set_orm_helpers
      # say "Configuring testing files for #{current_orm} app"
      inside test_path do                
        make_empty_dir(spec_integration_dir)
        copy_orm_helper
        copy_tests
      end
    end

    protected

    include Mengine::Base

    # the orm_helper.rb is put in the root of the dummy app spec folder 
    def copy_orm_helper
      FileUtils.cp src_file, target_file
      replace_content target_file, 'dummy_app_name', dummy_app_name
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

    def copy_test_files *files
      Mengine::Templates.new(root_path, dummy.dummy_spec, test_type).copy_test_files(*files)
    end

    def replace_orm_in_files *files
      inside dummy_spec.path do
        files.each {|file| replace_orm_in file}
      end
    end

    def dummy_spec
      dummy.dummy_spec
    end

    def dummy_app
      dummy.dummy_app
    end
    
    def orm_config_method
      "config_#{orm}"
    end

    def test_path
      test_type
    end

    def replace_orm_in file
      return if !File.exist?(file)
      [['orm', orm], ['path', dummy_spec.app_path], ['camelized', dummy_app.class_name]].each do |pair|
        replace_content file, pair[0], pair[1]
      end
    end

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

    def test_helper_path
      File.join(root_path, 'test_helpers', test_path).gsub /.+\/\//, ''
    end

    def active_record?
      !orm || ['active_record', 'ar'].include?(orm)
    end

    def orm_helper
      "#{orm}_helper.rb"
    end

    def spec_integration_dir
      dummy_spec.named_dir 'integration'
    end

    def navigation_file
      templates.navigation_file
    end

    def dummy_file
      templates.dummy_file
    end
  end
end