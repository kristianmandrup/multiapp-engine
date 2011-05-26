module Mengine
  module Base    
    def exec_command command
      Kernel::system command
    end    

    def exec command
      inside sandbox_location do
        Kernel::system command
      end
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
    
    def make_empty_dir name
      empty_directory(name) unless File.directory?(name)
    end
    
    def matching_dummy_apps
      dummy_apps.select {|app| matches_any_orm?(app, orms) }
    end

    def apps_matching orm
      dummy_apps.select {|app| app =~ /#{orm}$/ }       
    end

    def matches_any_orm? app, orms
      orms.any? {|orm| app =~ /#{orm}$/ }       
    end

    def dummy_apps
      FileList.new "dummy-*"
    end        
  end
end