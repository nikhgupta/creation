require 'spec_helper'

describe "Creation with default configuration, but without home page" do
  before(:all){ @output = run_creation "--skip-home-page"}
  context "with README" do
    xit "readme should list the change"
  end
  context "with home page" do
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*skipped.*default.*home\s*page/)
      expect(@output).not_to match(/^\s*create.*default.*home\s*page/)
      expect(@output).not_to match(/^\s*create.*home\.html\.erb/)
      expect(@output).not_to match(/^\s*home_page.*links/)
    end
    it "does not add relevant gem(s) to Gemfile" do
      expect("gem 'high_voltage'").not_to         be_in_gemfile
    end
    it "does not set up home page view and routes" do
      expect(Dir).not_to  find("app/views/pages")
      expect(File).not_to find("app/views/pages/home.html.erb")
      expect("root to: 'high_voltage/pages#show'").not_to be_in_routes
    end
    it "does not link to home page in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+root_path.*?\s*%\>/
      expect(content).not_to be_present_in("app/views/layouts/application.html.erb")
    end
    it "does not link to admin backend login in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+admin_dashboard_path.*?\s*%\>/
      expect(content).to be_present_in("app/views/layouts/application.html.erb")
    end
  end
  context "twitter bootstrap (for frontend)" do
    before{ @layout = "app/views/layouts/application.html.erb" }
    it "provides concise information on CLI" do
      expect(@output).to  match(/^\s*setup\s+.*bootstrap/)
      expect(@output).not_to match(/^\s*create.*bootstrap/)
    end
    it "adds relevant gem(s) to Gemfile" do
      expect("gem 'bootstrap-generators'").to be_in_gemfile
    end
    it "runs the related generator" do
      expect(@output).to match(/^\s*bundle.*generate bootstrap:install --force/)

      %w( lib/templates/erb/controller/view.html.erb
          lib/templates/erb/scaffold/edit.html.erb
          lib/templates/erb/scaffold/index.html.erb
          lib/templates/erb/scaffold/new.html.erb
          lib/templates/erb/scaffold/show.html.erb
          lib/templates/erb/scaffold/_form.html.erb
          app/assets/stylesheets/bootstrap-generators.scss
          app/assets/stylesheets/bootstrap-variables.scss
      ).each{ |file| expect(File).to find(file) }

      expect("navbar-collapse").to        be_present_in(@layout)
      expect('data-toggle="collapse"').to be_present_in(@layout)
      expect("require bootstrap").to      be_present_in("app/assets/javascripts/application.js")
    end
    it "brands app with its name" do
      expect(@output).to match(/^\s*bootstrap.*brand/)
      expect(/link_to\s+\"DummyApp\"/).to  be_present_in(@layout)
      expect("<title>DummyApp</title>").to be_present_in(@layout)
      expect("project name").not_to        be_present_in(@layout)
      expect("starter template for bootstrap").not_to be_present_in(@layout)
    end
  end
end

