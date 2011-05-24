# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec
  
  # # include MyHelpers module in every acceptance spec
  # config.include MyHelpers, :type => :acceptance
  # 
  # config.before(:each, :type => :acceptance) do
  #   # Some code to run before any acceptance spec
  # end
  
end
