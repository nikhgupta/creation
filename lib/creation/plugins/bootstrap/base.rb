module Creation::Plugins::Bootstrap
  class Base < Creation::Plugins::Base
    skip_option "Skip Twitter Bootstrap (frontend framework) integration"
    add_skip_option :home_page, "Do not add a home page"
    add_skip_option :flat_ui,   "Do not install Flat UI theme"

    def init_plug
      gem "bootstrap-generators"
      bundle_exec "rails generate bootstrap:install --force"
      post_bundle_task :fix_application_layout, "Add links and fix up application layout"
    end

    def add_flat_ui_optional
      gem "flat-ui-sass", github: 'wingrunr21/flat-ui-sass'
      append_file "app/assets/javascripts/application.js", '//= require flat-ui'
      post_bundle_task :add_flat_ui_to_assets, "Add Flat UI files to /app/assets"
    end

    def add_home_page_optional
        gem "high_voltage"
        copy_file "home.html.erb", "app/views/pages/home.html.erb"
        route "root to: 'high_voltage/pages#show', id: 'home'"
    end

    def fix_application_layout
      layout_file = "app/views/layouts/application.html.erb"
      # fix up project title in layout
      gsub_file layout_file, /project\s+name/i, app_name.titleize
      gsub_file layout_file, "Starter Template for Bootstrap", app_name.titleize

      # add links to navigation
      nav_html  = "<ul class='nav navbar-nav'><li class='active'><%= link_to 'Home', root_path %></li></ul>"
      if enabled?(:active_admin)
        nav_html += "\n<ul class='nav navbar-nav navbar-right'><li><%= link_to 'Login to #{options["admin_namespace"].titleize} Area', #{options["admin_namespace"]}_dashboard_path %></li></ul>"
      end
      gsub_file(layout_file, /<ul class="nav navbar-nav">.*?<\/ul>/mi, nav_html)
      gsub_file(layout_file, '"#", class: "navbar-brand"', 'root_path, class: "navbar-brand"')

      # fix up an issue with flash messages
      gsub_file(layout_file, '#{ name == :error ?', '#{%w[error alert].include?(name.to_s) ?')

      # remove text decoration from navbar links
      navbar_link_css = ".navbar {\n  a {\n     text-decoration: none;\n  }\n}"
      append_file("app/assets/stylesheets/bootstrap-generators.scss", navbar_link_css)
    end

    def add_flat_ui_to_assets
      file = "app/assets/stylesheets/bootstrap-generators.scss"
      gsub_file(file, "bootstrap-variables.scss", "flat-ui/variables")
      insert_into_file(file, "\n@import \"flat-ui\";", after: '@import "bootstrap.scss";')

      stylesheet_tag = "\n  <%= stylesheet_link_tag 'application', 'http://fonts.googleapis.com/css?family=Lato&subset=latin,latin-ext', media: 'screen' %>"
      insert_into_file("app/views/layouts/application.html.erb", stylesheet_tag, before: "\n  <%= csrf_meta_tags %>")

      append_file("config/initializers/assets.rb", "Rails.application.config.assets.precompile += %w( flat-ui/**/*.png )")
    end
  end
end

__END__

name:     Bootstrap
purpose:  frontend framework
category: integration
default:  false

options:
  home_page:
    default: false
    skip:    Do not add a home page
  flat_ui:
    default: false
    ukip:    Do not add FlatUI theme
