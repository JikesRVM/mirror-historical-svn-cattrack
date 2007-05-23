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
class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cattrack_session_id'

  self.check_environment

  # Load all active Records. Required here so
  # that present before next step and occurs at every application_reset!
  ActiveRecord::Base.preload_active_records
  # Setup all the relationships and validations based on db schema
  ActiveRecord::Base.init_auto_validations

  protected
  helper_method :menu_name
  def menu_name
    nil
  end

  def protect?
    false
  end

  # don't try to redirect to resource after authentication
  def store_location?
    false
  end

  # redirect unauthenticated user agent to login page when attempting to access resource requiring authentication
  def access_denied!
    if not is_authenticated?
      @skip_quicklinks = true
      render(:template => 'security/login_required', :status => 403)
    else
      render(:template => 'security/access_denied', :status => 403)
    end
    # TODO: should log or notify admin
  end
end
