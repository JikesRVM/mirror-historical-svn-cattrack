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
  verify :method => :get, :only => [:index], :redirect_to => {:action => :index}
  session :off

  def index
    name = 'core'
    @test_run_pages, @test_runs =
      paginate(:test_run, :per_page => 20, :order => 'occured_at DESC', :conditions => ['name = ?', name])
  end
end
