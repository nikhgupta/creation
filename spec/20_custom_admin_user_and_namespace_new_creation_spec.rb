require 'spec_helper'

describe "Creation with user model: member, and admin namespace: backend" do
  before(:all){ @output = run_creation "--admin-user=member --admin-namespace=backend" }
  context "with README" do
    xit "readme should list the change"
  end
  context "pundit (for authorization)" do
    it "adds default member policy" do
      file = "app/policies/member_policy.rb"
      expect("class MemberPolicy").to be_present_in(file)
      expect(/def index\?\s+member\.admin\?\s+end/m).to be_present_in(file)
      expect(/def create\?\s+member\.admin\?\s+end/m).to be_present_in(file)
      expect("member.admin? ? scope.all : scope.where(id: @member)").to be_present_in(file)
    end
  end
  context "active_admin (for admin backend)" do
    before(:all){ @initializer = "config/initializers/active_admin.rb" }
    it "provides concise information on CLI" do
      expect(@output).to     match(/^\s*bundle.*migration AddAdminToMembers admin:boolean/)
      expect(@output).not_to match(/^\s*create.*app\/admin\/member\.rb/)
    end
    it "runs the related generator" do
      expect(@output).to match(/^\s*bundle.*generate active_admin:install Member --registerable/)
      # expect(@output).to match(/generate\s+devise:install/)

      %w( app/models/member.rb
            spec/models/member_spec.rb
            app/admin/member.rb
      ).each{|file| expect(File).to find(file)}
      %w( app/models/user.rb
            spec/models/user_spec.rb
            app/admin/user.rb
      ).each{|file| expect(File).not_to find(file)}

      expect(Dir).to find("db/migrate/*devise_create_members.rb")
      expect("devise_for :members, ActiveAdmin::Devise.config").to be_in_routes
      expect("devise :database_authenticatable").to be_present_in("app/models/member.rb")
    end
    it "mounts activeadmin at /backend" do
      expect(/^\s*config\.default_namespace\s*=\s*:backend$/).to be_present_in(@initializer)
      expect(/^\s*config\.namespace\(:backend\) do/).to be_present_in(@initializer)
    end
    it "adds an admin field for the member model" do
      expect(@output).to match(/^\s*bundle.*generate migration AddAdminToMembers admin:boolean/)
      expect("column :admin").to be_present_in("app/admin/member.rb")
    end
    it "adds seed data for testing members and authentication" do
      content = "Member.find_by(email: 'admin@example.com').update_attribute :admin, true"
      expect(content).to be_present_in("db/seeds.rb")
      content = "Member.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password')"
      expect(content).to be_present_in("db/seeds.rb")
    end
  end
end

