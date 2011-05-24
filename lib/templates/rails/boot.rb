require 'rubygems'          
dir = '../../../../../'
gemfile = File.expand_path("#{dir}Gemfile", __FILE__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
end

$:.unshift File.expand_path("#{dir}lib", __FILE__)