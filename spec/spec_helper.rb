$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'yaml'
require 'pathname'
require 'fileutils'
require 'creation'

Dir['./spec/support/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.include CreationTestHelpers

  config.before(:all) do
    create_tmp_directory
    remove_project_directory
  end
end

module Creation
  module Generators
    class AppGenerator
      def run_bundle command
        bundle_command "install --local"
        bundle_command "install"
      end
    end
  end
end
