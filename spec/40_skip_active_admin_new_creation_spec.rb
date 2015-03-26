require 'spec_helper'

describe "Creation with default configuration, but without activeadmin" do
  before(:all){ @output = run_creation "--skip-active-admin"}
  context "with README" do
    xit "readme should list the change"
  end
  context "with home page" do
    it "does not link to admin backend login in layout" do
      content = /\<\%=\s*link_to\s+'.*?',\s+admin_dashboard_path.*?\s*%\>/
      expect(content).not_to be_present_in("app/views/layouts/application.html.erb")
    end
  end
  context "pundit (for authorization)" do
    it "does not add default user policy" do
      expect(File).not_to find("app/policies/user_policy.rb")
    end
    it "does not add comment policy for activeadmin" do
      expect(File).not_to find("app/policies/active_admin/comment_policy.rb")
    end
    it "does not add page policy for activeadmin" do
      expect(File).not_to find("app/policies/active_admin/page_policy.rb")
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
  context "active_admin (for admin backend)" do
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*skipped.*active_admin/)
      expect(@output).not_to match(/^\s*setup\s+active_admin/)
      expect(@output).not_to match(/^\s*bundle.*migration AddAdminToUsers admin:boolean/)
      expect(@output).not_to match(/^\s*active_admin.*config/)
      expect(@output).not_to match(/^\s*bundle.*generate migration AddAdminToUsers admin:boolean/)
    end
    it "does not add relevant gem(s) to Gemfile" do
      expect("gem 'devise'").not_to be_in_gemfile
      expect("gem 'activeadmin', github: 'activeadmin'").not_to be_in_gemfile
    end
    it "does not run related generator" do
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

      expect("devise_for :users, ActiveAdmin::Devise.config").not_to be_in_routes
      expect("ActiveAdmin.routes(self)").not_to be_in_routes
    end
    it "does not add seed data for testing users and authentication" do
      content = "User.find_by(email: 'admin@example.com').update_attribute :admin, true"
      expect(content).not_to be_present_in("db/seeds.rb")
      content = "User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password')"
      expect(content).not_to be_present_in("db/seeds.rb")
    end
  end
end
