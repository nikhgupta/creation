require 'spec_helper'

describe "Creation with root admin namespace" do
  before(:all){ @output = run_creation "--admin-namespace=" }
  it "does not have a root route defined explicitely" do
    expect(/^\s*root to:/).not_to be_in_routes
  end
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
      expect("gem 'high_voltage'").not_to be_in_gemfile
    end
    it "does not add home page view and routes" do
      expect(File).not_to find("app/views/pages/home.html.erb")
      expect(/^\s*root to: 'high_voltage\/pages#show'/).not_to be_in_routes
    end
    it "does not link to home page in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+root_path.*?\s*%\>/
      expect(content).not_to be_present_in("app/views/layouts/application.html.erb")
    end
    it "does not link to admin backend login in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+admin_dashboard_path.*?\s*%\>/
      expect(content).not_to be_present_in("app/views/layouts/application.html.erb")
    end
  end
  context "twitter bootstrap (for frontend)" do
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*skipped\s+.*bootstrap/)
      expect(@output).not_to match(/^\s*setup\s+.*bootstrap/)
      expect(@output).not_to match(/^\s*create.*bootstrap/)
      expect(@output).not_to match(/^\s*bootstrap.*brand/)
    end
    it "does not add relevant gem(s) to Gemfile" do
      expect("gem 'bootstrap-generators'").not_to be_in_gemfile
    end
    it "does not run the related generator" do
      expect(@output).not_to match(/^\s*bundle.*generate bootstrap:install --force/)
      %w( lib/templates/erb/controller/view.html.erb
          lib/templates/erb/scaffold/edit.html.erb
          lib/templates/erb/scaffold/index.html.erb
          lib/templates/erb/scaffold/new.html.erb
          lib/templates/erb/scaffold/show.html.erb
          lib/templates/erb/scaffold/_form.html.erb
          app/assets/stylesheets/bootstrap-generators.scss
          app/assets/stylesheets/bootstrap-variables.scss
      ).each{ |file| expect(File).not_to find(file) }

      layout     = "app/views/layouts/application.html.erb"
      javascript = "app/assets/javascripts/application.js"
      expect("navbar-collapse").not_to        be_present_in(layout)
      expect('data-toggle="collapse"').not_to be_present_in(layout)
      expect("require bootstrap").not_to      be_present_in(javascript)
    end
  end
  context "active_admin (for admin backend)" do
    before(:all){ @initializer = "config/initializers/active_admin.rb" }
    it "mounts activeadmin at /" do
      expect(/^\s*config\.default_namespace\s*=\s*false$/).to be_present_in(@initializer)
      expect(/^\s*config\.namespace\(false\) do/).to be_present_in(@initializer)
    end
  end
end

