require 'spec_helper'

describe "Creation with default configuration, but without sidekiq" do
  before(:all){ @output = run_creation "--skip-sidekiq"}
  context "with README" do
    xit "readme should list the change"
  end
  context "sidekiq (for background processing)" do
    it "provides concise information on CLI" do
      expect(@output).to      match(/^\s*skipped.*sidekiq/)
      expect(@output).not_to  match(/^\s*setup.*sidekiq/)
      expect(@output).not_to  match(/^\s*gemfile\s+sidekiq/)
    end
    it "does not add relevant gem(s) to Gemfile" do
      expect("gem 'sidekiq'").not_to be_in_gemfile
      expect("gem 'sinatra', require: false").not_to be_in_gemfile
    end
    it "does not create requisite directories" do
      expect(Dir).not_to find("app/jobs")
    end
    it "does not add default configuration" do
      expect(File).not_to find("config/sidekiq.yml")
    end
    it "does not get mounted" do
      expect("require 'sidekiq/web'\n").not_to be_in_routes
      expect(/^[^\#].*mount Sidekiq::Web/).not_to be_in_routes
    end
  end
  context "active_admin (for admin backend)" do
    before(:all){ @initializer = "config/initializers/active_admin.rb" }
    it "does not provide link to Sidekiq Monitoring dashboard" do
      expect("sidekiq_web_path").not_to be_present_in("config/initializers/active_admin.rb")
    end
  end
end

