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
class Reports::TestRunByRevisionReportController < ApplicationController
  verify :method => :get, :redirect_to => :access_denied_url
  caches_page :show
  session :off

  def show
    host = Tdm::Host.find_by_name(params[:host_name])
    raise CatTrack::SecurityError unless host
    test_run = host.test_runs.find_by_id_and_variant(params[:test_run_id], params[:test_run_variant])
    raise CatTrack::SecurityError unless test_run
    test_run.host = host # Avoid loads when rendering
    @report = Report::TestRunByRevision.new(test_run)
  end
end
