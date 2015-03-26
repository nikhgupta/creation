require 'spec_helper'

describe "Creation with default configuration, but without bootstrap" do
  before(:all){ @output = run_creation "--skip-bootstrap"}
  context "with README" do
    xit "readme should list the change"
  end
  context "with home page" do
    before do
      @layout   = "app/views/layouts/application.html.erb"
      @homepage = "app/views/pages/home.html.erb"
    end
    it "provides concise information on CLI" do
      expect(@output).to  match(/^\s*create\s+.*default.*home\s*page/)
      expect(@output).not_to match(/^\s*create.*home\.html\.erb/)
    end
    it "adds relevant gem(s) to Gemfile" do
      expect("gem 'high_voltage'").to be_in_gemfile
    end
    it "sets up home page view and routes" do
      expect(/you can edit/i).to be_present_in(@homepage)
      expect(/<%=\s+Rails\.application\.class\.parent_name.*%>/).to be_present_in(@homepage)
      expect("root to: 'high_voltage/pages#show', id: 'home'").to be_in_routes
    end
    it "links to home page in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+root_path.*?\s*%\>/
      expect(content).to be_present_in(@layout)

      content = '<li class="active"><a href="#">Home</a></li>'
      expect(content).not_to be_present_in(@layout)
    end
    it "links to admin backend login in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+admin_dashboard_path.*?\s*%\>/
      expect(content).to be_present_in(@layout)
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
end

