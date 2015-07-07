class Creation::Plugins::Base
  include Creation::ActionMethods

  class << self
    def add_option(*args)
      Creation::Generators::AppGenerator.class_option(*args)
    end

    def inherited(subclass)
      message = "Skip #{subclass.identifier.camelize} setup"
      option  = "skip_#{subclass.identifier}"
      add_option option, type: :boolean, default: false, desc: message
    end

    def skip_option(message)
      option = "skip_#{identifier}"
      add_option option, type: :boolean, default: false, desc: message
    end

    def add_skip_option option, message
      option = "#{identifier}_skip_#{option.to_s.underscore}"
      message = "[#{self.identifier.camelize}] #{message}"
      add_option option, type: :boolean, default: false, desc: message
    end

    def identifier
      name.to_s.underscore.gsub(/^creation\/plugins\//, '').gsub(/\/base/, '')
    end
  end

  def post_bundle_task name, message = nil
    after_bundle do
      message ||= name.to_s.humanize
      notify message, type: :task
      shell.mute { send(name) }
    end
  end

  def run_optional_tasks
    methods = self.methods.select{|m| m.to_s =~ /^add_.*_optional$/}
    methods.each do |method|
      option = method.to_s.gsub(/^add_(.*)_optional$/, '\1')
      if enabled?(self, option)
        send method
      else
        notify "Skipped installing: #{option.to_s.camelize}", type: :warn
      end
    end
  end

  def to_s
    self.class.identifier
  end

  def bundle_exec command, options = {}
    after_bundle do
      bundle_command "exec #{command}", { title: self.class.identifier }.merge(options)
    end
  end

  def enabled?(plugin, option = nil)
    option = option.blank? ? "skip_#{plugin}" : "#{plugin}_skip_#{option}"
    options.has_key?(option) && options[option] == false
  end

  def enabled_plugins?(*plugins)
    plugins.all?{|plugin| enabled?(plugin)}
  end

  def enabled_options?(plugin, *options)
    options.all?{|option| enabled?(plugin, option)}
  end

  def notify message, options = {}
    title = self.class.identifier
    title = :creation if title.to_s == "base"
    shell.notify message, { title: title }.merge(options)
  end

  def init_plug
    return unless instance_of?(Creation::Plugins::Base)
    install_useful_gems
    add_example_configs
    post_bundle_task :update_readme, "Update README"
  end

  def update_readme
    remove_file "README.rdoc"
    template "README.md", "README.md"
  end

  def install_useful_gems
    gem 'better_errors', group: :development
    gem 'binding_of_caller', group: :development
    gem "pry-rails", group: [:test, :development]
    gem 'dotenv-rails', group: [:test, :development]
  end

  # NOTE: do not generate example files via template method, as that would
  # leave the original secret keys in the firstever commit of this rails app.
  def add_example_configs
    inside("config") do
      run "mv secrets.yml  secrets.example.yml"
      run "mv database.yml database.example.yml"

      template "secrets.yml"
      template "databases/#{options[:database]}.yml", "database.yml"

      git rm: "--cache secrets.yml database.yml > /dev/null"
    end
    append_file ".gitignore", "\nconfig/secrets.yml\nconfig/database.yml"
  end
end
