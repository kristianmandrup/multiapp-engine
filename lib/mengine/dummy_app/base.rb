module Mengine
  class DummyApp 
    module Base
      def class_name
        name.camelize
      end

      # the path to the dummy app 
      # - fx spec/dummy-apps/dummy-mongoid
      def dummy_path    
        File.join(container_path, name)
      end

      def config_path
        File.join dummy_path, 'config'
      end

      # the path to the application file of a dummy app 
      # - fx spec/dummy-apps/dummy-mongoid/config/application.rb
      def application_file
        config_file 'application.rb'
      end

      def boot_file
        config_file 'boot.rb'
      end

      def config_file file
        File.join config_path, file
      end
    end
  end
end