require 'spec_helper'

describe "Creation with default configuration, but without rspec" do
  before(:all){ @output = run_creation "--skip-rspec"}
  context "with README" do
    xit "readme should list the change"
  end
  context "rspec (for test-driven development)" do
    it "provides concise information on CLI" do
      expect(@output).to      match(/^\s*skipped.*rspec/)
      expect(@output).not_to  match(/^\s*setup\s+rspec/)
      expect(@output).not_to  match(/^\s*gemfile\s+rspec-rails/)
    end
    it "does not add relevant gem(s) to Gemfile" do
      expect("gem 'rspec-rails', group: [:test, :development]").not_to be_in_gemfile
    end
    it "does not run the related generator, and does not create directories" do
      expect(@output).not_to match(/^\s*bundle.*generate rspec:install/)

      expect(Dir).not_to  find("spec")
      expect(File).not_to find(".rspec")
    end
  end
end

