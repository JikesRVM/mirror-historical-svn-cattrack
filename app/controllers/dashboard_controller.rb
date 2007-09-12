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
class DashboardController < ApplicationController
  verify :method => :get, :only => [:index], :redirect_to => :access_denied_url
  session :off

  def index
    @test_run_pages, @test_runs =
      paginate(Tdm::TestRun, :per_page => 20, :order => 'start_time DESC')

    @most_recent = Tdm::TestRun.find_recent()
  end
end
