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
class TestRunController < ApplicationController
  verify :method => :get, :only => [:show, :list], :redirect_to => {:action => :index}
  verify :method => :post, :only => [:destroy], :redirect_to => {:action => :index}

  def show
    @record = TestRun.find(params[:id])
  end

  def show_summary
    @record = TestRun.find(params[:id])
  end

  def destroy
    raise AuthenticatedSystem::SecurityError unless current_user.admin?
    @record = TestRun.find(params[:id])
    flash[:notice] = "#{@record.label} was successfully deleted."
    @record.destroy
    redirect_to(:action => 'list')
  end
end
