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
class RemoveExcludedTests < ActiveRecord::Migration
  class ResultDimension < ActiveRecord::Base
    set_table_name 'result_dimension'
  end

  class Measure < ActiveRecord::Base
  end

  def self.up
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute("DELETE FROM test_cases WHERE result = 'EXCLUDED'")
      result = ResultDimension.find_by_name('EXCLUDED')
      if result
        ActiveRecord::Base.connection.execute("DELETE FROM result_facts WHERE result_id = #{result.id}")
        ActiveRecord::Base.connection.execute("DELETE FROM statistic_facts WHERE result_id = #{result.id}")
        result.destroy
      end
      measure = Measure.find_by_name("Excluded Rate")
      measure.destroy if measure
    end
  end

  def self.down
  end
end
