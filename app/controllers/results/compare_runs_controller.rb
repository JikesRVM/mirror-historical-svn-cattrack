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
class Results::CompareRunsController < Results::BaseController
  verify :method => :get, :only => [:show], :redirect_to => :access_denied_url
  caches_page :show
  session :off

  helper Results::TestRunHelper

  def compare_two_runs
    return unless params[:firstRun]
    return unless params[:secondRun]
    first_test_run = Tdm::TestRun.find_by_id(params[:firstRun])
    second_test_run = Tdm::TestRun.find_by_id(params[:secondRun])
    @report = Report::RunComparisionReport.new(first_test_run, second_test_run)
  end
end
