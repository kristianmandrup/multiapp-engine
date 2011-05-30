require 'rake'
require 'active_support/inflector'

module Mengine
  module Executor    
    def run_dummy_generator name, *args
      cmd = "dummy #{name} #{args.flatten.join(' ')}"
      say "Run dummy generator: #{cmd}", :green
      exec_command cmd
    end

    def exec_command command
      Kernel::system command
    end    

    def exec command, app_name = nil
      inside sandbox_app_path(app_name) do
        Kernel::system command
      end
    end
    
    def bundle_update
      exec 'bundle update'
    end    
  end
end