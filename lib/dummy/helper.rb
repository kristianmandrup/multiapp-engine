require 'active_support/inflector'

module Dummy
  module Helper
    def make_arg name, value = nil, escape = false
      key = "--#{name.to_s.dasherize}"
      val = value ? value : "#{send name}"
      val = escape ? "'#{val}'" : val
      [key, val].join(' ')
    end
    
    def sandbox_location
      @sandbox_location ||= sandbox || '~/rails-dummies'
    end      

    def bundle_install bundle = nil
      say "bundle install"      
      exec 'bundle' if bundle
    end
    
    def dummy_apps
      FileList.new "#{dummy_apps_dir}/dummy-*"
    end

    def short_name name
      name.gsub /.+\/(.+)$/, '\1'
    end

    def short_dummy_apps
      dummy_apps.map {|path| short_name(path) }
    end

    def matching_dummy_apps
      short_dummy_apps.select {|app| matches_any_orm?(app, orms) }
    end

    def matches_any_orm? app, orms
      return true if orms.empty?
      orms.any? {|orm| app =~ /#{orm}$/ }       
    end

    def sandbox_apps
      FileList.new "#{sandbox_location}/dummy-*"
    end

    def short_sandbox_apps
      sandbox_apps.map {|path| short_name(path) }
    end

    def matching_sandbox_apps
      short_sandbox_apps.select {|app| matches_any_orm?(app, orms) }
    end

    def opts
      options[:command]
    end

    def command
      options[:command]
    end

    def orms
      options[:orms]
    end

    def sandbox
      options[:sandbox]
    end

    # def self.included(base)      
    #   base.class_options.each do |clsopt|
    #     class_eval %{
    #       def #{clsopt}
    #         options[:#{clsopt}]
    #       end        
    #     }
    #   end
    # end

    def dummy_apps_dir
      File.join(destination_root, dummy_apps_dir_relative)
    end

    def dummy_apps_dir_relative    
      File.join(app_test_path, 'dummy-apps')
    end

    def has_dummy_apps_dir?       
      File.directory? dummy_apps_dir
    end

    def app_test_path
      return 'test' if File.directory?('test')
      return 'spec' if File.directory?('spec')
      say "You must have a /spec or /test directory in the root of your project", :red
      exit(0)
    end        
  end
end