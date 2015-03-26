require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

# TODO: show detailed steps if user passes --verbose
# TODO: do not run the generator on error when bundling or any step
# TODO: separate home page and bootstrap integration
# TODO: lock version numbers for different gems used
# TODO: review the test suite
# TODO: last commit's message on skip-bundle step
# TODO: commits should be in a feature branch and then merged together
module Creation
  module Generators
    class AppGenerator < Rails::Generators::AppGenerator
      class Error < Thor::Error # :nodoc:
      end

      add_shared_options_for "application"

      class_option :no_creation,        type: :boolean,
                                        desc: "Skip Rails customization, altogether."

      class_option :skip_active_admin,  type: :boolean, aliases: "-a",
                                        desc: "Skip ActiveAdmin (admin backend framework) integration"

      class_option :skip_bootstrap,     type: :boolean, aliases: "-b",
                                        desc: "Skip Twitter Bootstrap (frontend framework) integration"

      class_option :skip_pundit,        type: :boolean,
                                        desc: "Skip Pundit (authorization) setup"

      class_option :skip_rspec,         type: :boolean,
                                        desc: "Skip RSpec (test suite) setup"

      class_option :skip_sidekiq,       type: :boolean,
                                        desc: "Skip Sidekiq (background processing) integration"

      class_option :skip_home_page,     type: :boolean,
                                        desc: "Skip adding default HomePage (via HighVoltage)"

      class_option :database,           type: :string, aliases: '-d', default: 'postgresql',
                                        desc: "Preconfigure for selected database"

      class_option :admin_namespace,    type: :string, default: 'admin',
                                        desc: "Admin namespace for ActiveAdmin. Use '' string for root namespace."

      class_option :admin_user,         type: :string, default: 'user',
                                        desc: "User model name for ActiveAdmin."

      def finish_template
        return super() if options["no_creation"].present?

        puts
        commit_updates "initial commit"
        # required just after bundle install for generators to work properly
        after_bundle { bundle_command "exec spring stop" }

        commit_updates :update, :readme, "switch to Markdown for README"
        commit_updates :secure, :config_files, "prevent sensitive config files from versioning"
        commit_updates :setup,  :useful_gems, "useful gems for smooth development workflows"
        commit_updates :setup,  :bootstrap, "add frontend framework using twitter bootstrap", if: options["admin_namespace"].present?
        commit_updates :create, :home_page, "add a default usable home page", if: options["admin_namespace"].present?
        commit_updates :setup,  :rspec, "rspec for test-driven development"
        commit_updates :setup,  :pundit, "pundit for user authorization"
        commit_updates :setup,  :active_admin, "active_admin for admin backend framework"
        commit_updates :setup,  :sidekiq, "sidekiq for background processing"

        super   # run leftovers

        after_bundle { commit_updates "customized rails, using `creation` gem" }
      end

      # def notes
      #   # run "rake notes:setup"

      #   say_status :setup, "Some of the tasks you need to complete now:", :magenta
      #   add_note :todo, "some todo"
      #   shell.padding += 1
      #   @notes.each{ |kind, message| say_status kind, message, :magenta } if @notes.present?
      #   shell.padding -= 1
      # end

      protected

      # def add_note kind, message
      #   @notes ||= []
      #   @notes <<  [ kind, message ]
      # end

      # args can take:
      # - message, block{}
      # - title, message, block{}
      # - title, method, *args, message, block{|args| .. }
      def commit_updates *args
        conditions = args.extract_options!

        message = args.pop
        title, meth, *args = args
        title ||= :commit

        should_skip = ( conditions.present? && (
          (conditions.has_key?(:if) && !conditions[:if]) ||
          (conditions.has_key?(:unless) && conditions[:unless])
        )) || ( meth.present? && !enabled?(meth))

        if should_skip
          say_status :skipped, "#{title}: #{message}", :yellow
          return
        end

        meth = "#{title}_#{meth}" if meth.present?
        raise Error, "No such builder method: #{meth}" unless meth.blank? || builder.respond_to?(meth)

        shell.mute do
          builder.send meth, *args if meth.present?
          yield(*args) if block_given?

          git init: "-q"
          git add: "."
          git commit: "-qam '#{message}' >/dev/null"
        end

        say_status title, message, :magenta
      end

      def bundle_command command
        return unless bundle_install?
        log :bundle, command
        silent_yield { super }
      end

      def enabled?(*features)
        features.all?{|feat| options["skip_#{feat}"].blank?}
      end

      def bundle_patch name, message, &block
        after_bundle do
          say_status name, "[patch]: #{message}", :magenta
          silent_yield { yield }
        end
      end

      def silent_yield &block
        stdout  = $stdout
        $stdout = File.open(File::NULL, "w")
        $stdout.sync = true
        yield
        $stdout = stdout
      end

      # def describe_task name, message, options = {}, &block
      #   say_status name, message, options.fetch(:color, :magenta)
      #   shell.mute { yield if block_given? }
      # end

      def source_paths
        [ File.expand_path("../../../../templates/", __FILE__), self.class.source_root ]
      end

      def self.banner
        "creation new #{self.arguments.map(&:usage).join(' ')} [options]"
      end

      def self.default_generator_root
        file = File.expand_path(File.join("rails", generator_name), base_root)
        file if File.exists?(file)
      end

      def self.usage_path
        paths = [
          File.expand_path("../../../../USAGE", __FILE__),
          source_root && File.expand_path("../USAGE", source_root),
          default_generator_root && File.join(default_generator_root, "USAGE")
        ]
        paths.compact.detect { |path| File.exist? path }
      end

      def get_builder_class
        return ::AppBuilder if defined?(::AppBuilder)
        return Creation::AppBuilder if defined?(Creation::AppBuilder)
        Rails::AppBuilder
      end
    end
  end
end
