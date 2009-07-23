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
module Report::RegressionReportMailerHelper
  def test_run_label(test_run,test_runs)
    include_time = test_runs.find_all do |tr|
      tr != test_run and tr.start_time.yday == test_run.start_time.yday and tr.start_time.year == test_run.start_time.year
    end.size > 0
    if include_time
      test_run.start_time.strftime('%d/%m<br/>%H:%M')
    else
      test_run.start_time.strftime('%d/%m')
    end
  end
end
