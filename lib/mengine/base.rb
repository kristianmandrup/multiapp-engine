require 'active_support/inflector'

module Mengine
  module Base    
    def make_arg name, value = nil, escape = false
      key = "--#{name.to_s.dasherize}"
      val = value ? value : "#{send name}"
      val = escape ? "'#{val}'" : val
      [key, val].join(' ')
    end

    def short_name name
      name.gsub /.+\/(.+)$/, '\1'
    end

    def translate orm
      case orm.to_sym
      when :ar
        'active_record'
      else
        orm || 'active_record'
      end
    end        
  end
end