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
class Report::PerformanceReport < Report::BaseTestRunByRevision
  # Input parameters
  attr_reader :test_run, :window_size

  # Output parameters
  attr_reader :test_runs, :statistics

  def initialize(test_run)
    super
  end
  
  private

  def perform
    super
    if not (@test_run['variant'] == 'perf') then 
      @statistics = get_perf_stats(nil)
    end
  end
end
