module Creation
  # This class tries to make minimal changes to the default build process, so as
  # to remain compatible with future versions of Rails' AppGnerator.
  class AppBuilder < Rails::AppBuilder
    include Creation::ActionMethods

    def update_readme
      remove_file "README.rdoc"
      template "README.md", "README.md"
    end

    # NOTE: do not generate example files via template method, as that would
    # leave the original secret keys in the firstever commit of this rails app.
    def secure_config_files
      inside("config") do
        run "mv secrets.yml  secrets.example.yml"
        run "mv database.yml database.example.yml"

        template "secrets.yml"
        template "databases/#{options[:database]}.yml", "database.yml"

        git rm: "--cache secrets.yml database.yml > /dev/null"
      end
      append_file ".gitignore", "\nconfig/secrets.yml\nconfig/database.yml"
    end

    def setup_useful_gems
      gem 'better_errors', group: :development
      gem 'binding_of_caller', group: :development
      gem "pry-rails", group: [:test, :development]
      gem 'dotenv-rails', group: [:test, :development]
    end

    def setup_test_suite
      gem_group :development do
        gem 'guard-rspec'
        gem 'guard-cucumber'
        gem 'terminal-notifier'
        gem 'terminal-notifier-guard'
      end

      gem_group :test do
        gem 'launchy'
        gem 'capybara'
        gem 'email_spec'
        gem 'shoulda-matchers'
        gem 'database_cleaner'
        gem 'simplecov', require: false
        gem 'cucumber-rails', require: false
      end

      gem_group :test, :development do
        gem 'rspec-rails'
        gem 'factory_girl_rails'
      end

      after_bundle do
        bundle_command "exec rails generate rspec:install"
        bundle_command "exec rails generate cucumber:install"
        bundle_command "exec rails generate email_spec:steps"
        bundle_command "exec guard init &>/dev/null"
      end

      # guard
      bundle_patch :guard, "open HTML page when Integration test fails in Cucumber" do
        inject_into_file("Guardfile", ", command_prefix: 'DEBUG=open'", after: 'guard "cucumber"')
      end

      # rspec
      create_file "spec/models/.keep"
      create_file "spec/support/.keep"
      create_file "spec/routing/.keep"
      create_file "spec/factories/.keep"
      bundle_patch :rspec, "load support files in spec/support directory" do
        gsub_file('spec/rails_helper.rb', /^\# Dir\[Rails\.root\.join/, 'Dir[Rails.root.join')
      end

      # simplecov
      simplecov = <<-DATA.gsub(/^ {8}/, '')
        # simplecov configuration
        require 'simplecov'
        SimpleCov.start 'rails' do
          add_group 'Policies', 'app/policies'
          add_group 'Extractors', 'app/extractors'
          add_group 'SidekiqJobs', 'app/jobs'
        end
        SimpleCov.command_name 'RSpec'

      DATA

      bundle_patch :simplecov, "add configuration to run Simplecov" do
        inject_into_file("spec/rails_helper.rb", simplecov, after: "ENV['RAILS_ENV'] ||= 'test'\n")
        prepend_to_file("features/support/env.rb", simplecov.gsub("RSpec", "Cucumber"))
      end

      # Cucumber and RSpec helper files
      bundle_patch :rspec, "add support files for various gems" do
        directory "rspec/support", "spec/support"
      end
      bundle_patch :cucumber, "add support files for various gems, and some step definitions" do
        directory "cucumber/support", "features/support"
        directory "cucumber/step_definitions", "features/step_definitions"
        inject_into_file("features/support/env.rb", "\nrequire 'email_spec'\nrequire 'email_spec/cucumber'", after: "require 'cucumber/rails'")
      end

      if enabled?(:active_admin)
        bundle_patch :factory_girl, "adding User factory" do
          copy_file "factories/users.rb", "spec/factories/users.rb"
        end
      end

      append_file(".gitignore", "coverage/*")
    end

    def setup_bootstrap
      gem "bootstrap-generators"

      after_bundle do
        bundle_command "exec rails generate bootstrap:install --force"
      end

      bundle_patch :bootstrap, "add branding to home page" do
        layout_file = "app/views/layouts/application.html.erb"
        gsub_file layout_file, /project\s+name/i, app_name.titleize
        gsub_file layout_file, "Starter Template for Bootstrap", app_name.titleize

        navbar_link_css = ".navbar {\n  a {\n     text-decoration: none;\n  }\n}"
        append_file("app/assets/stylesheets/bootstrap-generators.scss", navbar_link_css)
      end
    end

    def create_home_page
      gem "high_voltage"

      copy_file "home.html", "app/views/pages/home.html.erb"
      route "root to: 'high_voltage/pages#show', id: 'home'"

      # Update the application layout, so generated, to present a nice homepage
      # OPTIMIZE: maybe, add this as a separate template?
      # FIXME: what happens when not using bootstrap?
      bundle_patch :home_page, "add important links to home page" do
        layout_file = "app/views/layouts/application.html.erb"
        nav_html  = "<ul class='nav navbar-nav'><li class='active'><%= link_to 'Home', root_path %></li></ul>"
        nav_html += "\n<ul class='nav navbar-nav navbar-right'><li><%= link_to 'Login to #{options["admin_namespace"].titleize} Area', #{options["admin_namespace"]}_dashboard_path %></li></ul>" if enabled?(:bundle, :active_admin)
        insert_into_file layout_file, nav_html, before: /\n\s*<%=\s*yield\s*%>/
        if enabled?(:bootstrap)
          gsub_file(layout_file, /<ul class="nav navbar-nav">.*?<\/ul>/mi, nav_html)
          gsub_file(layout_file, '"#", class: "navbar-brand"', 'root_path, class: "navbar-brand"')
        end
      end
    end

    def setup_flat_ui
      return unless enabled?(:bootstrap)
      gem "flat-ui-sass", github: 'wingrunr21/flat-ui-sass'
      append_file "app/assets/javascripts/application.js", '//= require flat-ui'

      bundle_patch :flat_ui, "add Flat UI theming for bootstrap" do
        file = "app/assets/stylesheets/bootstrap-generators.scss"
        gsub_file(file, "bootstrap-variables.scss", "flat-ui/variables")
        insert_into_file(file, "\n@import \"flat-ui\";", after: '@import "bootstrap.scss";')

        stylesheet_tag = "\n  <%= stylesheet_link_tag 'application', 'http://fonts.googleapis.com/css?family=Lato&subset=latin,latin-ext', media: 'screen' %>"
        insert_into_file("app/views/layouts/application.html.erb", stylesheet_tag, before: "\n  <%= csrf_meta_tags %>")

        append_file("config/initializers/assets.rb", "Rails.application.config.assets.precompile += %w( flat-ui/**/*.png )")
      end
    end

    def setup_pundit
      gem "pundit"
      inject_into_class "app/controllers/application_controller.rb", "ApplicationController", "  include Pundit\n"

      template "policies/application/application_policy.rb", "app/policies/application_policy.rb"
      if enabled? :active_admin
        directory "policies/active_admin", "app/policies/active_admin"
        template "policies/application/user_policy.rb", "app/policies/#{options["admin_user"].underscore}_policy.rb"
      end
    end

    def setup_active_admin
      gem "devise"
      gem "activeadmin", github: "activeadmin"

      # add default_url_options to environments
      environment "config.action_mailer.default_url_options = {host: 'localhost', port: 3000}\n", env: 'test'
      environment "config.action_mailer.default_url_options = {host: 'localhost', port: 3000}\n", env: 'development'
      environment "# TODO: uncomment this before deployment to production\n  # config.action_mailer.default_url_options = {host: 'localhost', port: 3000}\n", env: 'production'

      user_klass = options["admin_user"].camelize
      namespace  = options["admin_namespace"].blank? ? "false" : ":#{options["admin_namespace"].underscore}"

      # customize AA to behave as per user intended for.
      custom_aa_config = <<-CONFIG.gsub(/^ {2}/, '').strip
        # Custom configuration for ActiveAdmin (added via template)
        config.site_title_link       = "/"
        config.default_namespace     = #{namespace}
        config.show_comments_in_menu = false
        #{enabled?(:pundit) ? "config.authorization_adapter = ActiveAdmin::PunditAdapter\n" : ""}
        config.namespace(#{namespace}) do |namespace|
          namespace.download_links = false
          namespace.build_menu :default do |menu|
          #{enabled?(:sidekiq) ? "menu.add label: 'Monitor', url: ->{ sidekiq_web_path }, priority: 999, html_options: { target: :blank }, if: proc{ current_user.admin? }" : ""}
          end
        end
      CONFIG

      # add `admin` field to activeadmin, and create some test users
      append_file "db/seeds.rb", "\n#{user_klass}.find_by(email: 'admin@example.com').update_attribute :admin, true"
      append_file "db/seeds.rb", "\n#{user_klass}.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password')"

      after_bundle do
        bundle_command "exec rails generate active_admin:install #{user_klass} --registerable"
        bundle_command "exec rails generate migration AddAdminTo#{user_klass.pluralize} admin:boolean"
      end

      bundle_patch :active_admin, "modify generated configuration" do
        insert_into_file "app/admin/#{user_klass.underscore}.rb", "    column :admin\n", after: "column :email\n"
        insert_into_file "config/initializers/active_admin.rb", "\n\n  #{custom_aa_config}\n", after: /ActiveAdmin\.setup do.*$/
        append_file "app/assets/stylesheets/active_admin.scss", "#footer {\n  p { display: none; }\n}"
      end
    end

    def setup_sidekiq
      gem "sidekiq"
      gem "sinatra", require: false

      create_file 'app/jobs/.keep'
      copy_file "sidekiq.yml", "config/sidekiq.yml"

      prepend_to_file "config/routes.rb", "require 'sidekiq/web'\n"

      if enabled?(:pundit, :active_admin)
        # mount to active-admin user model
        route "authenticate :#{options["admin_user"]}, lambda { |u| u.admin? } do\n    mount Sidekiq::Web => '/monitor'\n  end"
      else
        route "mount Sidekiq::Web => '/monitor'"
      end
    end

    def run_leftovers
      add_postgres_database_rake if options["database"] == "postgresql"
      # TODO: remove test directory if test suite installed
    end

    def add_postgres_database_rake
      copy_file "database.rake", "lib/tasks/database.rake"
    end
  end
end
