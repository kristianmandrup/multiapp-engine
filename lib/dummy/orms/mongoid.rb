require 'dummy/orms/base'

module Dummy
  module Orms
    class MongoidInstaller < BaseInstaller      
      def initialize dummy
        super
      end
      
      def gem_statements
       %q{gem "mongoid"
gem "bson_ext"
}
      end      
    end
  end
end