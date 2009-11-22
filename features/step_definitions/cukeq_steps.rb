Given /^I have a master and (\d+) slaves running$/ do |n|
  start_master
  n.to_i.times { start_slave }
end

Given /^a report app is running$/ do
  start_report_app
end

Given /^I POST the following list to the master web service:$/ do |table|
  features = table.raw.flatten
  post(master_url, features.to_json)
end

Then /^the report app should know when the run has finished$/ do
  sleep 2 # heh.
end

Then /^I should be able to GET the results$/ do
  json = get(report_app.url + "/results")
  JSON.parse(json).size.should == 2
end
