module Creation::Plugins::Sidekiq
  class Base < Creation::Plugins::Base
    skip_option "Skip Sidekiq (background processing) integration"

    def init_plug
      gem "sidekiq"
      gem "sinatra", require: false

      create_file 'app/jobs/.keep'
      copy_file "sidekiq.yml", "config/sidekiq.yml"
      prepend_to_file "config/routes.rb", "require 'sidekiq/web'\n"

      if enabled_plugins?(:pundit, :active_admin)
        # mount to active-admin user model
        route "authenticate :#{options["admin_user"]}, lambda { |u| u.admin? } do\n    mount Sidekiq::Web => '/monitor'\n  end"
      else
        route "mount Sidekiq::Web => '/monitor'"
      end
    end
  end
end

__END__

name: Sidekiq
purpose: background processing
category: integration
