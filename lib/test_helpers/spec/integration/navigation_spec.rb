require '#path#/#orm#_helper'

describe "Navigation" do
  include Capybara
  
  it "should be a valid app" do
    ::Rails.application.should be_a(#camelized#::Application)
  end
end
