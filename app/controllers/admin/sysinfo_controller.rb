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
class Admin::SysinfoController < Admin::BaseController
  verify :method => :get, :only => [:show], :redirect_to => :access_denied_url
  verify :method => :post, :only => [:purge_stale_sessions], :redirect_to => :access_denied_url

  def show
  end

  def purge_stale_sessions
    SessionCleaner::remove_stale_sessions
    AuditLog.log('sys.purge_stale_sessions')
    redirect_to(:action => 'show')
  end
end
