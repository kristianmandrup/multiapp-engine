# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{multiengine}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Kristian Mandrup}]
  s.date = %q{2011-05-24}
  s.description = %q{Creates a Rails 3 engine configuration with multiple dummy apps and test framework configured and ready to go}
  s.email = %q{kmandrup@gmail.com}
  s.executables = [%q{mengine}]
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    "Gemfile",
    "MIT-LICENSE",
    "README.textile",
    "Rakefile",
    "bin/mengine",
    "lib/multi_engine.rb",
    "lib/templates/gitignore",
    "lib/templates/rails/application.rb",
    "lib/templates/rails/boot.rb",
    "lib/templates/root/%underscored%.gemspec.tt",
    "lib/templates/root/Gemfile.tt",
    "lib/templates/root/MIT-LICENSE.tt",
    "lib/templates/root/README.rdoc.tt",
    "lib/templates/root/Rakefile.tt",
    "lib/templates/root/lib/%underscored%.rb.tt",
    "lib/templates/spec/spec_config.rb.tt",
    "lib/templates/spec/spec_helper.rb",
    "lib/templates/spec/spec_init.rb.tt",
    "lib/templates/test/%underscored%_test.rb.tt",
    "lib/templates/test/config.rb.tt",
    "lib/templates/test/init.rb.tt",
    "lib/templates/test/integration/navigation_test.rb.tt",
    "lib/templates/test/orm/active_record_helper.rb.tt",
    "lib/templates/test/orm/mongoid_helper.rb.tt",
    "lib/templates/test/support/integration_case.rb",
    "lib/templates/test/test_helper.rb",
    "lib/test_helpers/spec/dummy_spec.rb",
    "lib/test_helpers/spec/integration/navigation_spec.rb",
    "lib/test_helpers/spec/orm/active_record_helper.rb",
    "lib/test_helpers/spec/orm/mongoid_helper.rb",
    "lib/xdummy.rb.inprogress"
  ]
  s.homepage = %q{http://github.com/kristianmandrup/multiapp-engine}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.3}
  s.summary = %q{Creates a Rails 3 engine configuration with multiple dummy apps for testing}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sqlite3>, [">= 0"])
      s.add_runtime_dependency(%q<rspec>, [">= 2.5"])
      s.add_runtime_dependency(%q<rspec-rails>, [">= 2.5"])
      s.add_runtime_dependency(%q<capybara>, ["~> 0.4"])
      s.add_runtime_dependency(%q<thor>, ["~> 0.14.6"])
      s.add_runtime_dependency(%q<rails>, ["~> 3.1.0.rc1"])
      s.add_runtime_dependency(%q<rake>, ["~> 0.9"])
      s.add_runtime_dependency(%q<sugar-high>, ["~> 0.4"])
    else
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.5"])
      s.add_dependency(%q<rspec-rails>, [">= 2.5"])
      s.add_dependency(%q<capybara>, ["~> 0.4"])
      s.add_dependency(%q<thor>, ["~> 0.14.6"])
      s.add_dependency(%q<rails>, ["~> 3.1.0.rc1"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<sugar-high>, ["~> 0.4"])
    end
  else
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.5"])
    s.add_dependency(%q<rspec-rails>, [">= 2.5"])
    s.add_dependency(%q<capybara>, ["~> 0.4"])
    s.add_dependency(%q<thor>, ["~> 0.14.6"])
    s.add_dependency(%q<rails>, ["~> 3.1.0.rc1"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<sugar-high>, ["~> 0.4"])
  end
end

