module Creation
  module Generators
    class AppGenerator < Rails::Generators::AppGenerator
      class Error < Thor::Error # :nodoc:
      end

      add_shared_options_for "application"

      class_option :database, type: :string, aliases: '-d', default: 'postgresql',
        desc: "Preconfigure for selected database"

      class_option :no_creation, type: :boolean,
        desc: "Skip Rails customization, altogether."

      def finish_template
        super
        return if options["no_creation"].present?
        puts

        # commit whatever boilerplate was generated for us by Rails
        commit "initial commit"
        # stop spring since it interferes with generators
        build :bundle_exec, "spring stop"

        # run the plugins that we have
        run_enabled_plugins

        # finally, commit the changes if any.
        # ReadMe is updated here to ensure a commit is done.
        after_bundle do
          commit "customized rails, using `creation` gem"
        end
      end

      def run_bundle
        bundle_command('install --local') if bundle_install?
      end

      protected

      # Run all the plugins that are enabled, but make sure no gory details are
      # shown to the user.
      def run_enabled_plugins
        with_enabled_plugins do |plugin|
          plugin.greet
          within_muted_shell do
            plugin.run
            plugin.run_sub_routines
          end
          after_bundle{ plugin.finish }
        end
      end

      def plugin_options_for(plugin)
        plugin.class.options.reject do |option|
          options["skip_#{option}"].present?
        end
      end

      def with_enabled_plugins &block
        Creation.plugins.map do |klass|
          next if options["skip_#{klass.identifier}"].present?
          @builder = klass.new(self)
          yield(@builder) if block_given?
          @builder
        end.compact
      end

      def within_muted_shell &block
        shell.mute { yield }
        # stdout  = $stdout
        # $stdout = File.open(File::NULL, "w")
        # $stdout.sync = true
        # yield
        # $stdout = stdout
      end

      def bundle_command command, options = {}
        return unless bundle_install?
        shell.notify command, { type: :bundle }.merge(options)
        within_muted_shell { super(command) }
      end

      def commit message, options = {}
        identifier = options.fetch(:as, :base)
        within_muted_shell do
          git init: "-q"
          git add: "."
          git commit: "-qam '[#{identifier}]: #{message}' >/dev/null"
        end

        if $?.exitstatus == 0 && options.fetch(:announce, true)
          shell.notify message, type: :commit
        end
      end

      def source_paths
        [ File.expand_path("../../../../templates/", __FILE__),
          self.class.source_root,
          File.expand_path("../../plugins/#{builder.class.identifier}/templates/", __FILE__) ]
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
        return Creation::Plugins::Base if defined?(Creation::Plugins::Base)
        Rails::AppBuilder
      end

      # def builder
      #   @builder ||= begin
      #     builder_class = get_builder_class
      #     builder_class.include(ActionMethods)
      #     builder_class.new(self)
      #   end
      # end
    end
  end
end
