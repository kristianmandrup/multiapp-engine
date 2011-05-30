module Mengine
  class DummyApp 
    class Argumentor
      attr_reader :dummy_app
      
      def initialize dummy_app
        @dummy_app = dummy_app
      end

      # name of dummy generator, fx :create
      def generator_arguments_for dummy_gen
        send dummy_arg_method(dummy_gen) if respond_to? dummy_arg_method(dummy_gen)
      end

      protected
      
      def dummy_arg_method name
        "dummy_#{name}_args"
      end        

      def default_args
        args = []
        args << make_arg(:apps, name)        
        args << make_arg(:test_framework, test_framework)
        args
      end

      def dummy_ormconfig_args
        default_args << make_arg(:orm, orm)
        default_args        
      end

      def dummy_create_args
        default_args << make_arg(:opts, option_args.join(' '), true)
        default_args        
      end      

      private
      
      def name
        dummy_app.name 
      end

      def option_args
        dummy_app.option_args
      end      
    end
  end
end
      
      