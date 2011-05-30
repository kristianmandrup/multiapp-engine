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
      @sandbox_location ||= sandbox || File.expand_path('~/rails-dummies')
    end      

    def bundle_install bundle = nil
      say "bundle install"      
      exec 'bundle' if bundle
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