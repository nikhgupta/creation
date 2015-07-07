module Creation::Plugins::TestSuite
  class Base < Creation::Plugins::Base
    skip_option "Skip Test Suite (rspec, cucumber, simplecov, etc.) setup"

    def init_plug
      add_required_gems
      create_git_keep_files

      bundle_exec "rails generate rspec:install"
      bundle_exec "rails generate cucumber:install"
      bundle_exec "rails generate email_spec:steps"
      bundle_exec "guard init &>/dev/null"

      post_bundle_task :open_html_page_when_failed,
        "open HTML page when Integration test fails in Cucumber"

      post_bundle_task :add_simplecov_config, "add configuration to run Simplecov"

      post_bundle_task :rspec_add_support_files,
        "[RSpec] add support files for various gems"

      post_bundle_task :cucumber_add_support_files,
        "add support files for various gems, and some step definitions"

      post_bundle_task :add_user_factory if enabled?(:active_admin)
    end

    def add_required_gems
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
    end

    def create_git_keep_files
      %w[spec/models spec/support spec/routing spec/factories
      spec/controllers features/step_definitions features/support ].each do |dir|
        create_file "#{dir}/.keep"
      end
    end

    def open_html_page_when_failed
      inject_into_file("Guardfile", ", command_prefix: 'DEBUG=open'", after: 'guard "cucumber"')
    end

    def rspec_add_support_files
      gsub_file('spec/rails_helper.rb', /^\# Dir\[Rails\.root\.join/, 'Dir[Rails.root.join')
      directory "rspec/support", "spec/support"
    end

    def cucumber_add_support_files
      directory "cucumber/support", "features/support"
      directory "cucumber/step_definitions", "features/step_definitions"
      inject_into_file("features/support/env.rb", "\nrequire 'email_spec'\nrequire 'email_spec/cucumber'", after: "require 'cucumber/rails'")
    end

    def add_simplecov_config
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
      inject_into_file("spec/rails_helper.rb", simplecov, after: "ENV['RAILS_ENV'] ||= 'test'\n")
      prepend_to_file("features/support/env.rb", simplecov.gsub("RSpec", "Cucumber"))
      append_file(".gitignore", "coverage/*")
    end

    def add_user_factory
      remove_file "spec/factories/users.rb"
      copy_file "factories/users.rb", "spec/factories/users.rb"
    end
  end
end

__END__

name: Sidekiq
purpose: background processing
category: integration

