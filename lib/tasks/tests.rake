#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Common Public License (CPL);
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

Rake::Task['test'].prerequisites << 'test:services'

namespace :test do
  Rake::TestTask.new(:helpers => ["db:test:prepare", :environment]) do |t|
    t.libs << "test"
    t.pattern = 'test/helpers/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:helpers'].comment = "Run the helper tests in test/helpers"
end

Rake::Task['test'].prerequisites << 'test:helpers'

desc "Run the continuous integration action"
task :cia => ['clear', 'test'] do
end
