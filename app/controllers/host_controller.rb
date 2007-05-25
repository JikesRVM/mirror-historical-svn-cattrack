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
class HostController < ApplicationController
  verify :method => :get, :only => [:show, :list], :redirect_to => {:action => :index}
  session :off

  def show
    @record = Host.find(params[:id])
    @test_run_pages, @test_runs =
      paginate(:test_run, :per_page => 20, :order => 'occured_at DESC', :conditions => ['host_id = ?', @record.id])
  end

  def list
    @record_pages, @records = paginate(:host, :per_page => 20, :order => 'name')
  end
end
