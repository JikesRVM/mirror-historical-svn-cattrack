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
class TestCaseController < ApplicationController
  verify :method => :get, :only => [:show, :show_output], :redirect_to => :access_denied_url
  caches_page :show, :show_output
  session :off

  def show
    @record = TestCase.find(params[:id])
  end

  def show_output
    @record = TestCase.find(params[:id])
    headers['Content-Type'] = 'text/plain'
    render(:text => @record.output, :layout => false)
  end
end
