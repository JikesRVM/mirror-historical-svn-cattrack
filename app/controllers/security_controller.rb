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
class SecurityController < ApplicationController
  verify :method => :get, :only => [:administrators, :access_denied], :redirect_to => :access_denied_url
  verify :method => :post, :only => [:logout], :redirect_to => :access_denied_url

  filter_parameter_logging :password

  def login
    if request.post?
      self.current_user = User.authenticate(params[:username], params[:password])
      if self.current_user
        cookies[:cattrack_admin] = current_user.admin?.to_s
        cookies[:cattrack_user] = current_user.username
        redirect_to_url(:controller => 'dashboard')
      else
        flash[:alert] = 'Incorrect Login or Password.'
      end
    end
  end

  def administrators
  end

  def access_denied
    render(:template => 'security/access_denied', :status => 403)
  end

  def logout
    cookies.delete :cattrack_admin
    cookies.delete :cattrack_user
    self.current_user = nil
    flash[:notice] = 'You have been logged out.'
    redirect_to(:action => 'login')
  end

  protected
  def protect?
    false
  end
end
