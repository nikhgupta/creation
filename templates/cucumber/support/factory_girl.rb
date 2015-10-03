World(FactoryGirl::Syntax::Methods)
begin
  DatabaseCleaner.start
  FactoryGirl.lint
ensure
  DatabaseCleaner.clean_with(:truncation)
end

