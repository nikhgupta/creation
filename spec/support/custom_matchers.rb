RSpec::Matchers.define :be_present_in do |file|
  match do |excerpt|
    content = project_path(file.to_s).read
    excerpt.is_a?(Regexp) ? content.match(excerpt) : content.include?(excerpt)
  end

  failure_message do |excerpt|
    "expected #{file} to include:\n  #{excerpt}"
  end

  failure_message_when_negated do |excerpt|
    "expected #{file} to not include:\n  #{excerpt}"
  end

  description do
    "be included in: #{file}"
  end
end

RSpec::Matchers.define :find do |file|
  match do |klass|
    path = project_path(file.to_s).to_s
    case
    when klass == Dir then Dir[path].any?
    when klass.respond_to?(:exists?) then klass.exists?(path)
    end
  end

  failure_message do
    "expected that #{file} would exist inside project"
  end

  failure_message_when_negated do
    "expected that #{file} would not exist inside project"
  end

  description do
    "be able to find #{file} inside project"
  end
end

RSpec::Matchers.define :be_in_gemfile do
  match do |gemspec|
    content = project_path("Gemfile").read
    gemspec.is_a?(Regexp) ? content.match(gemspec) : content.include?(gemspec)
  end

  failure_message do |gemspec|
    "expected project's Gemfile to have:\n#{gemspec}"
  end

  failure_message_when_negated do |gemspec|
    "expected project's Gemfile to not have:\n#{gemspec}"
  end

  description do
    "be present in project's Gemfile"
  end
end

RSpec::Matchers.define :be_in_routes do
  match do |route|
    content = project_path("config/routes.rb").read
    route.is_a?(Regexp) ? content.match(route) : content.include?(route)
  end

  failure_message do |route|
    "expected project's routes to have:\n#{route}"
  end

  failure_message_when_negated do |route|
    "expected project's routes to not have:\n#{route}"
  end

  description do
    "be present in project's routes"
  end
end

RSpec::Matchers.define :be_in_stdout do
  match do |content|
    content.is_a?(Regexp) ? @output.match(content) : @output.include?(content)
  end

  failure_message do |content|
    "expected STDOUT to include:\n  #{content}"
  end

  failure_message_when_negated do |content|
    "expected STDOUT to not include:\n  #{content}"
  end

  description do
    "be present in STDOUT"
  end
end

RSpec::Matchers.define :be_in_environment do |env|
  match do |config|
    content = project_path("config/environments/#{env}.rb").read
    config.is_a?(Regexp) ? content.match(config) : content.include?(config)
  end

  failure_message do |config|
    "expected project's #{env} environment config to have:\n#{config}"
  end

  failure_message_when_negated do |config|
    "expected project's #{env} environment config to not have:\n#{config}"
  end

  description do
    "be present in project's #{env} environment config"
  end
end
