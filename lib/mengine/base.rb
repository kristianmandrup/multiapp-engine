require 'rake'

module Mengine
  module Base    
    def exec_command command
      Kernel::system command
    end    

    def exec app_name, command
      inside sandbox_app_path(app_name) do
        Kernel::system command
      end
    end

    def sandbox_app_path name
      File.join(sandbox_location, name)
    end

    def bundle_update
      exec 'bundle update'
    end

    def translate orm
      case orm.to_sym
      when :ar
        'active_record'
      else
        orm
      end
    end        
  end
end