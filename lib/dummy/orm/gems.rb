module Dummy
  module Orm
    module Gems
      def install_gems orm
        case orm.to_sym 
        when :mongoid
          # puts gems into Gemfile and runs bundle to install them, then runs install and config generators
          run_dummy_generator :install, install_gen_arguments        
        end
      end    

      def install_gen_arguments
        ["--gems mongoid bson_ext", "--orms mongoid"] 
      end 
      
      def gemfile
        'Gemfile'
      end
    end
  end
end