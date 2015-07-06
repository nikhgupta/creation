module Creation
  module ActionMethods
    include Rails::ActionMethods

    %w(gem gem_group).each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(*args, &block)
            @generator.send(:#{method}, *args, &block)
          end
      RUBY
    end
    def configure_file file, config, options = {}
      padding  = options.fetch :padding, 2
      config   = "\n\n#{(" " * padding)}#{config}"
      sentinel = "\n#{" " * (padding - 2)}end"
      inject_into_file file, config, before: sentinel
    end

    def configure_application_file(config)
      configure_file "config/application.rb", config, padding: 4
    end

    def configure_environment(rails_env, config)
      configure_file "config/environments/#{rails_env}.rb", config
    end
  end
end

