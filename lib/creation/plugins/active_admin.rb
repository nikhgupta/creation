class Creation::Plugins::ActiveAdmin < Creation::Plugins::Base
  skip_option "Skip ActiveAdmin (admin backend) integration"
  add_option :admin_namespace, type: :string, default: 'admin',
    desc: "Admin namespace for ActiveAdmin. Use '' string for root namespace."
  add_option :admin_user, type: :string, default: 'user',
    desc: "User model name for ActiveAdmin."

  def user_class
    options["admin_user"].camelize
  end

  def namespace
    options["admin_namespace"]
  end

  def ns_string
    namespace.blank? ? "false" : ":#{namespace.underscore}"
  end

  def init_plug
    gem "devise"
    gem "activeadmin", github: "activeadmin"
    add_default_url_options
    create_test_users
    bundle_exec "rails generate active_admin:install #{user_class} --registerable"
    bundle_exec "rails generate migration AddAdminTo#{user_class.pluralize} admin:boolean"
    post_bundle_task :modify_config, "modify generated configuration"
  end

  def add_default_url_options
    environment "config.action_mailer.default_url_options = {host: 'localhost', port: 3000}\n", env: 'test'
    environment "config.action_mailer.default_url_options = {host: 'localhost', port: 3000}\n", env: 'development'
    environment "# TODO: uncomment this before deployment to production\n  # config.action_mailer.default_url_options = {host: 'localhost', port: 3000}\n", env: 'production'
  end

  # FIXME: admin@example.com is not set as User.
  # NOTE:  This is due to the fact that db/seeds is run along with db:migrate,
  # which results in a race condition, probably. Sleeping for a moment will
  # solve this.
  def create_test_users
    sleep 3
    # add `admin` field to activeadmin, and create some test users
    append_file "db/seeds.rb", "\n#{user_class}.find_by(email: 'admin@example.com').update_attribute :admin, true"
    append_file "db/seeds.rb", "\n#{user_class}.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password')"
  end

  def modify_config
    # customize AA to behave as per user intended for.
    custom_aa_config = <<-CONFIG.gsub(/^ {2}/, '').strip
      # Custom configuration for ActiveAdmin (added via template)
      config.site_title_link       = "/"
      config.default_namespace     = #{ns_string}
      config.show_comments_in_menu = false
    #{enabled?(:pundit) ? "config.authorization_adapter = ActiveAdmin::PunditAdapter\n" : ""}
      config.namespace(#{ns_string}) do |namespace|
        namespace.download_links = false
        namespace.build_menu :default do |menu|
    #{enabled?(:sidekiq) ? "menu.add label: 'Monitor', url: ->{ sidekiq_web_path }, priority: 999, html_options: { target: :blank }, if: proc{ current_user.admin? }" : ""}
        end
      end
    CONFIG

    insert_into_file "app/admin/#{user_class.underscore}.rb",
      "    column :admin\n", after: "column :email\n"
    insert_into_file "config/initializers/active_admin.rb",
      "\n\n  #{custom_aa_config}\n", after: /ActiveAdmin\.setup do.*$/
    append_file "app/assets/stylesheets/active_admin.css.scss",
      "#footer {\n  p { display: none; }\n}"
  end
end

__END__

name: ActiveAdmin
purpose: admin backend
category: integration
