# Navigation
Given /^(?:|I )(?:am on|go to) (.+)$/ do |page_name|
  visit path_to(page_name)
end
Then /^(?:|I )should( not)? be on (.+)$/ do |negate, page_name|
  if !negate
    expect(page.current_path).to eq(path_to(page_name))
  else
    expect(page.current_path).not_to eq(path_to(page_name))
  end
end
When /^(?:|I )click on "(.*?)"$/ do |link|
  case
    when has_button?(link) then click_button(link)
    when has_link?(link)   then click_link(link)
    else fail "no such link or button found: #{link}"
  end
end

# Page content
Then /^(?:|I )should( not)? see "(.*?)"$/ do |negate, text|
  if !negate
    expect(page).to have_content(text)
  else
    expect(page).not_to have_content(text)
  end
end
Then /^(?:|I )should( not)? see link to "(.*?)"$/ do |negate, link|
  find_link = find(:xpath, "//a[@href='#{link}']")
  if negate
    expect{ find_link }.to raise_error(Capybara::ElementNotFound)
  else
    expect( find_link ).to be_present
  end
end
Then /^(?:|I )should( not)? see link with text "(.*?)"$/ do |negate, link|
  if !negate
    expect(page).to have_link(link)
  else
    expect(page).not_to have_link(link)
  end
end

# Forms
Then /^I should( not)? see field "(.*?)" prefilled with "(.*?)"$/ do |negate, field, value|
  expect(page).to have_field(field)
  if negate
    expect(page.find_field(field).value).not_to eq(value)
  else
    expect(page.find_field(field).value).to eq(value)
  end
end

