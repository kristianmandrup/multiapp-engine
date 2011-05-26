module Mengine
  class Templates
    attr_accessor :dummy_spec
    
    def initialize dummy_spec, test_dir
      @dummy_spec = dummy_spec
      @test_dir = test_dir
    end
    
    def copy_test_files *files
      files.each do |file| 
        FileUtils.cp src_file(file), target_file(file) if File.exist?(file)
      end
    end

    protected

    def target_file file
      File.join dummy_spec.app_dir, file
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

    def test_path
      rspec? ? "spec" : "test"
    end
    alias_method :test_ext, :test_path
  end
end