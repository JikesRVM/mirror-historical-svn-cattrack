#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
namespace :test do
  Rake::TestTask.new(:services => ["db:test:prepare", :environment]) do |t|
    t.libs << "test"
    t.pattern = 'test/services/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:services'].comment = "Run the service tests in test/services"
end

namespace :test do
  Rake::TestTask.new(:helpers => ["db:test:prepare", :environment]) do |t|
    t.libs << "test"
    t.pattern = 'test/helpers/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:helpers'].comment = "Run the helper tests in test/helpers"
end

desc "Run the continuous integration action"
task :cia => ['clear', 'test'] do
end

Rake.application.instance_variable_get("@tasks").delete_if {|key, value| key == 'test'}

desc 'Test all units and functionals'
task :test do
  Rake::Task["test:units"].invoke rescue got_error = true
  Rake::Task["test:helpers"].invoke rescue got_error = true
  Rake::Task["test:services"].invoke rescue got_error = true
  Rake::Task["test:functionals"].invoke rescue got_error = true
  Rake::Task["test:integration"].invoke rescue got_error = true

  raise "Test failures" if got_error
end

