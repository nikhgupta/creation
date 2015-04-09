require 'spec_helper'

describe "Creation with database: sqlite3" do
  before(:all){ @output = run_creation "-d sqlite3" }
  context "with database" do
    it "sets up sqlite3 as default database" do
      expect("adapter: sqlite3").to be_present_in("config/database.example.yml")
    end
    it "does not add database.rake for aiding in dropping databases easily" do
      expect(File).not_to find("lib/database.rake")
    end
  end
end
