module Mengine
  class Templates
    attr_accessor :dummy_spec
    
    def initialize dummy
      @dummy_spec = dummy_spec
      @test_dir = test_dir
      @root_path = root_path
    end
    
    def copy_test_files *files
      files.each do |file| 
        FileUtils.cp src_file(file), target_file(file) if File.exist?(src_file(file))
      end
    end

    protected

    def test_helper_path
      File.join(root_path, 'test_helpers', test_dir).gsub /.+\/\//, ''
    end

    def target_file file
      File.join dummy_spec.app_path, file
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