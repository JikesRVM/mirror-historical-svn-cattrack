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
class Results::TestRunController < Results::BaseController
  verify :method => :post, :only => [:destroy], :redirect_to => :access_denied_url
  cache_sweeper :test_run_sweeper, :only => [:destroy]

  def show
    @record = TestRun.find(params[:id])
  end

  def show_summary
    @record = TestRun.find(params[:id])
  end

  def destroy
    raise AuthenticatedSystem::SecurityError unless is_authenticated?
    @record = TestRun.find(params[:id])
    raise AuthenticatedSystem::SecurityError unless current_user.admin?
    flash[:notice] = "#{@record.label} was successfully deleted."
    @record.destroy
    redirect_to(:controller => '/host', :action => 'show', :id => @record.host_id)
  end
end
