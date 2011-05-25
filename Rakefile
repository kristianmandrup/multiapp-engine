# encoding: UTF-8
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Multi Engine'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "multiengine"
    s.version = "0.5.1"
    s.summary = "Creates a Rails 3 engine configuration with multiple dummy apps for testing"
    s.email = "kmandrup@gmail.com"
    s.homepage = "http://github.com/kristianmandrup/multiapp-engine"
    s.description = "Creates a Rails 3 engine configuration with multiple dummy apps and test framework configured and ready to go"
    s.authors = ['Kristian Mandrup']
    s.files =  FileList["[A-Z]*", "lib/**/*", "bin/*"]
    s.bindir = "bin"
    s.executables = %w(mengine dummy)
    s.add_dependency  "thor",       "~> 0.14.6"
    s.add_dependency  "rails",      "~> 3.1.0.rc1"
    s.add_dependency  "rake",       "~> 0.9"
    s.add_dependency  "sugar-high", "~> 0.4"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end
