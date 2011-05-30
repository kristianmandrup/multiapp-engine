module Mengine
  class Config 
    attr_reader :root_path, :engine_config
    
    def initialize root_path, engine_config
      @root_path = root_path
      @engine_config = engine_config
    end

    # .gsub /.+\/\//, ''
    def test_helper_path
      @test_helper_path ||= File.join(root_path, 'test_helpers', engine_config.test_folder)
    end
  end
end
    