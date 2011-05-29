require 'rake'
require 'active_support/inflector'

module Mengine
  module Base    
    def run_dummy_generator name, *args
      cmd = "dummy #{name} #{args.flatten.join(' ')}"
      say "run: #{cmd}"      
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

    def make_arg name, value = nil, escape = false
      key = "--#{name.to_s.dasherize}"
      val = value ? value : "#{send name}"
      val = escape ? "'#{val}'" : val
      [key, val].join(' ')
    end

    def sandbox_app_path name = nil
      name ? File.join(sandbox_location, name) : sandbox_location
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