Given /^I have a master and (\d+) slaves running$/ do |n|
  start_master
  n.to_i.times { start_slave }
end

Given /^a report app is running$/ do
  start_report_app
end

Given /^I POST the following list to the master:$/ do |table|
  features = table.raw.flatten
  post(master_url, features.to_json)
end

Then /^the reporter should know when the run has finished$/ do
  sleep 0.5 until report_app.finished?
end

Then /^I should be able to GET the results$/ do
  get(report_app.url + "/results").size.should == 2
end
