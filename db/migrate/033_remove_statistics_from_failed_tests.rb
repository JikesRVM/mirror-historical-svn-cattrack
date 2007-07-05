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
class RemoveStatisticsFromFailedTests < ActiveRecord::Migration
  class ResultDimension < ActiveRecord::Base
    set_table_name 'result_dimension'
  end

  def self.up
    ActiveRecord::Base.connection.execute("DELETE FROM test_case_numerical_statistics USING test_cases WHERE test_cases.result != 'SUCCESS' AND test_case_numerical_statistics.owner_id = test_cases.id")
    ActiveRecord::Base.connection.execute("DELETE FROM test_case_statistics USING test_cases WHERE test_cases.result != 'SUCCESS' AND test_case_statistics.owner_id = test_cases.id")

    result = ResultDimension.find_by_name('SUCCESS')
    ActiveRecord::Base.connection.execute("DELETE FROM statistic_facts WHERE result_id != #{result.id}") if result
  end

  def self.down
  end
end
