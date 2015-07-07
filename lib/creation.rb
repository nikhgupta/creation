require 'yaml'
require 'rails/generators'
require 'rails/generators/rails/app/app_generator'
require 'active_support/inflector'
require "creation/thor"
require "creation/version"
require "creation/action_methods"

module Creation
  ROOT_PATH = File.dirname(File.dirname(__FILE__))
  module Plugins
    class Base < Rails::AppBuilder
      include Creation::ActionMethods
    end
  end

  def self.plugins_root
    File.join(ROOT_PATH, "lib", "creation", "plugins")
  end

  def self.plugins
    @@plugins
  end

  def self.load_plugins
    plugins = ["*.rb", "*/base.rb"].map do |pattern|
      Dir.glob(File.join(plugins_root, pattern))
    end.flatten
    plugins.unshift File.join(plugins_root, "base.rb")

    @@plugins = plugins.uniq.map do |file|
      require file
      name = file.gsub(File.join(ROOT_PATH, "lib"), '')
      name = name.gsub(/\.rb$/, '') #.gsub(/\/base$/, '')
      name = (name.camelize.constantize rescue nil) if name.present?
      name if name.is_a?(Class) # && name != Creation::Plugins::Base
    end.compact
  end
end

require "creation/generators/app_generator"
Creation.load_plugins
