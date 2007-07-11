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
module Report::RegressionReportMailerHelper
  def test_run_label(test_run,test_runs)
    include_time = test_runs.find_all do |tr|
      tr != test_run and tr.occurred_at.yday == test_run.occurred_at.yday and tr.occurred_at.year == test_run.occurred_at.year
    end.size > 0
    if include_time
      test_run.occurred_at.strftime('%d/%m<br/>%H:%M')
    else
      test_run.occurred_at.strftime('%d/%m')
    end
  end
end
