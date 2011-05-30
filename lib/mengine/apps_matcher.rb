module Mengine
  class AppsMatcher
    attr_accessor :dummy_container, :orms, :apps
    
    def initialize dummy_container, options = {}
      @dummy_container = dummy_container
      @orms = options[:orms] || []
      @apps = options[:apps] || [nil]
    end
    
    def matching_dummy_apps
      dummy_app_names_found.select {|app| matches_any_orm?(app) }
    end

    def apps_matching orm
      apps.each do |name|
        dummy_app_names_found.select {|app| app =~ expr(name, orm) }       
      end
    end

    def expr name, orm = nil      
      /#{Regexp.escape(dummy_name name, orm )}$/
    end

    def dummy_name name, orm
      str = name if name
      str << orm if orm
      str.join('-')
    end

    def matches_any_orm? app_name
      return true if orms.empty?
      orms.any? {|orm| app_name =~ expr(nil, orm) }       
    end

    def dumy_container_path
      File.expand_path dummy_container_path
    end

    def dummy_app_names_found
      dummy_apps_found.map {|path| short_name(path) }      
    end

    def dummy_apps_found
      FileList.new File.join(dummy_container_path, "dummy-*")
    end 
    
    def short_name name
      name.gsub /.+\/(.+)$/, '\1'
    end           
  end
end