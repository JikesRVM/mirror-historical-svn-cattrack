#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
class Results::BuildConfigurationController < Results::BaseController
  verify :method => :get, :redirect_to => :access_denied_url
  caches_page :show, :show_output
  session :off

  def show
    @record = build_configuration
  end

  def show_output
    headers['Content-Type'] = 'text/plain'
    render(:text => build_configuration.output, :layout => false)
  end
end
