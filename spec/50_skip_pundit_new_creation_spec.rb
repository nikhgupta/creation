require 'spec_helper'

describe "Creation with default configuration, but without pundit" do
  before(:all){ @output = run_creation "--skip-pundit"}
  context "with README" do
    xit "readme should list the change"
  end
  context "pundit (for authorization)" do
    it "provides concise information on CLI" do
      expect(@output).to      match(/^\s*skipped.*pundit/)
      expect(@output).not_to  match(/^\s*setup\s+pundit/)
      expect(@output).not_to  match(/^\s*gemfile\s+pundit/)
    end
    it "does not add relevant gem(s) to Gemfile" do
      expect("gem 'pundit'").not_to be_in_gemfile
    end
    it "does not inject Pundit into ApplicationController" do
      content = /class ApplicationController.*\n\s*include Pundit\n.*\nend/m
      expect(content).not_to be_present_in("app/controllers/application_controller.rb")
    end
    it "does not add any policies" do
      expect(Dir).not_to find("app/policies/")
      expect(Dir).not_to find("app/policies/*")
    end
  end
  context "sidekiq (for background processing)" do
    it "mounts sidekiq dashboard to /monitor without authorization" do
      expect("require 'sidekiq/web'\n").to be_in_routes
      expect(/mount Sidekiq::Web => '\/monitor'/).to be_in_routes

      content = /authenticate.*lambda\s*\{.*admin\?\s*\}.*mount Sidekiq::Web => '\/monitor'\s*end/m
      expect(content).not_to be_in_routes
    end
  end
end
