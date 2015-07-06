class Creation::Plugins::Base
  include Creation::ActionMethods

  class << self
    def inherited(subclass)
      message = "Skip #{subclass.identifier.camelize} setup"
      Creation::Generators::AppGenerator.class_option "skip_#{subclass.identifier}",
        type: :boolean, desc: message
    end

    def skip_option(message)
      Creation::Generators::AppGenerator.class_option "skip_#{identifier}",
        type: :boolean, desc: message
    end

    def add_skip_option name, message
      name = name.to_s.underscore
      message = "[#{self.identifier.camelize}] #{message}"
      Creation::Generators::AppGenerator.class_option "skip_#{name}",
        type: :boolean, desc: message

      @@plugins ||= {}
      @@plugins[self.to_s] ||= {}
      @@plugins[self.to_s][:options] ||= []
      @@plugins[self.to_s][:options].push name
    end

    def greet_message(message)
      add_plugin_property name, :greet, message
    end

    def commit_message(message)
      add_plugin_property name, :commit, message
    end

    def identifier
      name.to_s.underscore.gsub(/^creation\/plugins\//, '').gsub(/\/base/, '')
    end

    def options
      @@plugins[name][:options] || []
    end

    private

    def add_plugin_property plugin, key, value
      @@plugins ||= {}
      @@plugins[plugin] ||= {}
      @@plugins[plugin][key] = value
    end
  end

  def greet
    message = @@plugins[self.class.name][:greet] || "Adding plugin: #{name}"
    notify message
  end

  def run; end

  def finish
    message = @@plugins[self.class.name][:greet] || "Configured plugin: #{name}"
    plugin_commit message
  end

  def post_bundle_task name, message = nil
    after_bundle do
      message ||= name.to_s.humanize
      notify message, type: :task
      within_muted_shell { send(name) }
      plugin_commit message, announce: false
    end
  end

  def plugin_commit message, options = {}
    commit message, { as: self.class.identifier }.merge(options)
  end

  def notify message, options = {}
    title = self.class.identifier
    title = :creation if title.to_s == "base"
    shell.notify message, { title: title }.merge(options)
  end

  def bundle_exec command, options = {}
    after_bundle do
      bundle_command "exec #{command}", { title: self.class.identifier }.merge(options)
    end
  end

  def run_sub_routines
    self.class.options.each do |option|
      if options["skip_#{option}"].present?
        notify "Skipped installing: #{option.to_s.camelize}", type: :warn
      else
        send("install_#{option}")
      end
    end
  end
end
