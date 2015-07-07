module Creation::Plugins::Pundit
  class Base < Creation::Plugins::Base
    skip_option "Skip Pundit (authorization) integration"

    def init_plug
      gem "pundit"
      inject_into_class "app/controllers/application_controller.rb", "ApplicationController", "  include Pundit\n"

      template "application_policy.rb", "app/policies/application_policy.rb"
      hook_into_active_admin if enabled_plugins?(:active_admin)
    end

    def hook_into_active_admin
      directory "active_admin", "app/policies/active_admin"
      template "user_policy.rb", "app/policies/#{options["admin_user"].underscore}_policy.rb"
    end
  end
end

__END__

name: Pundit
purpose: authorization
category: integration

