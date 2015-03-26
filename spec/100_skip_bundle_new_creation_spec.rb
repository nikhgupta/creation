require 'spec_helper'

describe "Creation when skipping bundle" do
  before(:all){ @output = run_creation "--skip-bundle" }

  xit "specs pass" do
    # inside_project_bundle{ expect(`rake`).to include('0 failures') }
  end
  context "with README" do
    before{ @readme = project_path("README.md") }
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*update\s+switch to Markdown for README/)
      expect(@output).not_to match(/^\s*remove\s+README.rdoc/)
    end
    it "switches to Markdown from RDoc" do
      expect(File).to       find("README.md")
      expect(File).not_to   find("README.rdoc")
      expect("DummyApp").to be_present_in("README.md")
    end
    xit "lists the customizations made"
  end
  context "useful gems" do
    it "provides concise information on CLI" do
      expect(@output).to  match(/^\s*setup\s+useful gems for smooth/)
    end
    it "adds pry for easy debugging" do
      expect(@output).not_to match(/^\s*gemfile\s+pry-rails/)
      expect("gem 'pry-rails', group: [:test, :development]").to be_in_gemfile
    end
  end
  context "with configuration files" do
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*secure\s+prevent sensitive config files/)
      expect(@output).not_to match(/^\s*run\s+git rm --cache/)
    end
    it "ignores sensitive files from versioning" do
      expect("\nconfig/secrets.yml").to  be_present_in(".gitignore")
      expect("\nconfig/database.yml").to be_present_in(".gitignore")
    end
    it "creates example copy, and regenerates files" do
      expect(File).to find("config/secrets.yml")
      expect(File).to find("config/database.yml")
      expect(File).to find("config/secrets.example.yml")
      expect(File).to find("config/database.example.yml")

      secrets_gen = YAML.load_file project_path("config", "secrets.yml").to_s
      secrets_exm = YAML.load_file project_path("config", "secrets.example.yml").to_s

      tst_key_new = secrets_gen["test"]["secret_key_base"]
      dev_key_new = secrets_gen["development"]["secret_key_base"]
      dev_key_exm = secrets_exm["development"]["secret_key_base"]

      expect(tst_key_new).not_to eq(dev_key_new)
      expect(dev_key_exm).not_to eq(dev_key_new)
    end
  end
  context "with home page" do
    before do
      @layout   = "app/views/layouts/application.html.erb"
      @homepage = "app/views/pages/home.html.erb"
    end
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*create\s+.*default.*home\s*page/)
      expect(@output).not_to match(/^\s*home_page.*links/)
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
    # TODO:  test that the generated is run forcefully
    # FIXME: test the links via integration/request tests
    it "links to home page in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+root_path.*?\s*%\>/
      expect(content).to be_present_in(@layout)

      content = '<li class="active"><a href="#">Home</a></li>'
      expect(content).not_to be_present_in(@layout)
    end
    it "does not link to admin backend login in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+admin_dashboard_path.*?\s*%\>/
      expect(content).not_to be_present_in(@layout)
    end
  end
  context "twitter bootstrap (for frontend)" do
    before{ @layout   = "app/views/layouts/application.html.erb" }
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*setup\s+.*bootstrap/)
      expect(@output).not_to match(/^\s*create.*bootstrap/)
      expect(@output).not_to match(/^\s*bootstrap.*brand/)
    end
    it "adds relevant gem(s) to Gemfile" do
      expect("gem 'bootstrap-generators'").to be_in_gemfile
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

      expect("navbar-collapse").not_to    be_present_in(@layout)
      expect("require bootstrap").not_to  be_present_in("app/assets/javascripts/application.js")
    end
    it "does not brand app with its name" do
      # expect(/link_to\s+\"DummyApp\"/).to  be_present_in(@layout)
      expect("<title>DummyApp</title>").to            be_present_in(@layout)

      expect("project name").not_to                   be_present_in(@layout)
      expect("starter template for bootstrap").not_to be_present_in(@layout)
    end
    xit "notifies the user of steps to follow"
  end
  context "rspec (for test-driven development)" do
    it "provides concise information on CLI" do
      expect(@output).to      match(/^\s*setup\s+rspec/)
      expect(@output).not_to  match(/^\s*gemfile\s+rspec-rails/)
    end
    it "adds relevant gem(s) to Gemfile" do
      expect("gem 'rspec-rails', group: [:test, :development]").to be_in_gemfile
    end
    it "creates requisite directories" do
      expect(File).to find("spec/models/.keep")
      expect(File).to find("spec/support/.keep")
      expect(File).to find("spec/routing/.keep")
    end
    it "does not run the related generator" do
      expect(@output).not_to match(/^\s*bundle.*generate rspec:install/)

      expect(File).not_to find("spec/spec_helper.rb")
      expect(File).not_to find("spec/rails_helper.rb")
      expect(File).not_to find(".rspec")
    end
    xit "notifies the user of steps to follow"
  end
  context "pundit (for authorization)" do
    it "provides concise information on CLI" do
      expect(@output).to      match(/^\s*setup\s+pundit/)
      expect(@output).not_to  match(/^\s*gemfile\s+pundit/)
    end
    it "adds relevant gem(s) to Gemfile" do
      expect("gem 'pundit'").to be_in_gemfile
    end
    it "injects Pundit into ApplicationController" do
      content = /class ApplicationController.*\n\s*include Pundit\n.*\nend/m
      expect(content).to be_present_in("app/controllers/application_controller.rb")
    end
    it "adds default application policy" do
      file = "app/policies/application_policy.rb"
      expect(/user\.admin\?.*scoped\?/).to         be_present_in(file)
      expect(/def scoped\?.*scope.where.*end/m).to be_present_in(file)
    end
    it "adds default user policy" do
      file = "app/policies/user_policy.rb"
      expect("class UserPolicy").to be_present_in(file)
      expect(/def index\?\s+user\.admin\?\s+end/m).to be_present_in(file)
      expect(/def create\?\s+user\.admin\?\s+end/m).to be_present_in(file)
      expect("user.admin? ? scope.all : scope.where(id: @user)").to be_present_in(file)
    end
    it "adds comment policy for activeadmin" do
      file = "app/policies/active_admin/comment_policy.rb"
      expect("class CommentPolicy").to be_present_in(file)
    end
    it "adds page policy for activeadmin" do
      file = "app/policies/active_admin/page_policy.rb"
      expect("class PagePolicy").to be_present_in(file)
    end
  end
  context "sidekiq (for background processing)" do
    it "provides concise information on CLI" do
      expect(@output).to      match(/^\s*setup\s+sidekiq/)
      expect(@output).not_to  match(/^\s*gemfile\s+sidekiq/)
    end
    it "adds relevant gem(s) to Gemfile" do
      expect("gem 'sidekiq'").to be_in_gemfile
      expect("gem 'sinatra', require: false").to be_in_gemfile
    end
    it "creates requisite directories" do
      expect(File).to find("app/jobs/.keep")
    end
    it "adds default configuration for itself" do
      expect(":pidfile: ./tmp/pids/sidekiq.pid").to be_present_in("config/sidekiq.yml")
    end
    # TODO: test that the new app requires authentication for /monitor
    it "mounts sidekiq dashboard to /monitor with authorization" do
      expect("require 'sidekiq/web'\n").to be_in_routes
      content = /authenticate.*lambda\s*\{.*admin\?\s*\}.*mount Sidekiq::Web => '\/monitor'\s*end/m
      expect(content).to be_in_routes
    end
  end
  context "active_admin (for admin backend)" do
    before(:all){ @initializer = "config/initializers/active_admin.rb" }
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*setup\s+active_admin/)
      expect(@output).not_to match(/^\s*active_admin.*config/)

      expect(@output).not_to match(/^\s*gemfile\s+devise/)
      expect(@output).not_to match(/^\s*gemfile\s+activeadmin/)
      expect(@output).not_to match(/app\/admin\/user\.rb/)
      expect(@output).not_to match(/^\s*bundle.*migration AddAdminToUsers admin:boolean/)
    end
    it "adds relevant gem(s) to Gemfile" do
      expect("gem 'devise'").to be_in_gemfile
      expect("gem 'activeadmin', github: 'activeadmin'").to be_in_gemfile
    end
    it "adds default_url_options for all environments" do
      content = /default_url_options = \{host: 'localhost', port: 3000\}$/
      expect(content).to be_in_environment(:test)
      expect(content).to be_in_environment(:development)

      expect(/\#.*#{content}/).to be_in_environment(:production)
      expect(/\# TODO:.*uncomment this.*/).to be_in_environment(:production)
    end
    it "does not run the related generator" do
      expect(@output).not_to match(/^\s*bundle.*generate active_admin:install User --registerable/)
      # expect(@output).to match(/generate\s+devise:install/)

      %w( config/initializers/devise.rb
          config/locales/devise.en.yml
          app/models/user.rb
          spec/models/user_spec.rb
          config/initializers/active_admin.rb
          app/admin/dashboard.rb
          app/admin/user.rb
          app/assets/javascripts/active_admin.js.coffee
          app/assets/stylesheets/active_admin.css.scss
      ).each{|file| expect(File).not_to find(file)}

      expect(Dir).not_to find("db/migrate/*devise_create_users.rb")
      expect(Dir).not_to find("db/migrate/*create_active_admin_comments.rb")

      expect("ActiveAdmin.routes(self)").not_to be_in_routes
      expect("devise_for :users, ActiveAdmin::Devise.config").not_to be_in_routes
    end
    xit "notifies the user of steps to follow"
  end
end

