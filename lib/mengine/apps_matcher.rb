module Mengine
  module AppsMatcher
    def matching_dummy_apps
      dummy_apps.select {|app| matches_any_orm?(app, orms) }
    end

    def apps_matching orm
      dummy_apps.select {|app| app =~ /#{orm}$/ }       
    end

    def matches_any_orm? app, orms
      orms.any? {|orm| app =~ /#{orm}$/ }       
    end

    def dummy_apps_path 
      File.join(test_type, apps_dir_name)
    end

    def dummy_apps
      FileList.new File.join(dummy_apps_path, "dummy-*")
    end        
  end
end