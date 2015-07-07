require "pp"
After do |scenario|
  save_and_open_page if scenario.failed? and (ENV["DEBUG"] == "open")
  pp(page) if ENV["DEBUG"] == "pp"
end

