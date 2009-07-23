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
class Admin::AuditLogController < Admin::BaseController
  verify :method => :get, :only => [:list], :redirect_to => :access_denied_url

  def list
    options = {}
    options[:order] = 'created_at DESC'
    options[:per_page] = 30
    options[:conditions] = ['name LIKE ?', "%#{params[:q]}%"] if params[:q]
    @audit_log_pages, @audit_logs = paginate(:audit_log, options)
  end
end
