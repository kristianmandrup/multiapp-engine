module Mengine
  module Dummy
    attr_accessor :dummy_spec, :dummy_app
    
    def initialize dummy_app
      @dummy_spec = DummySpec.new dummy_app.name
      @dummy_app = dummy_app      
    end        
    
    def create root_path, type, orm
      DummyApp.new root_path, type, orm
    end      
  end
end
