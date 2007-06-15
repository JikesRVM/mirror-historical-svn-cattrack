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
class Admin::UserController < Admin::BaseController
  verify :method => :get, :only => [:show,:list], :redirect_to => :access_denied_url
  verify :method => :post, :only => [:enable_admin, :disable_admin, :activate, :deactivate], :redirect_to => :access_denied_url

  def show
    @record = User.find(params[:id])
  end

  def list
    options = {}
    options[:order] = 'username'
    options[:per_page] = 20
    options[:conditions] = ['username LIKE ?', "%#{params[:q]}%"] if params[:q]
    @record_pages, @records = paginate(:user, options)
  end

  def enable_admin
    user = User.find(params[:id])
    user.admin = true
    user.save!
    redirect_to(:action => 'show', :id => user)
  end

  def disable_admin
    user = User.find(params[:id])
    user.admin = false
    user.save!
    redirect_to(:action => 'show', :id => user)
  end

  def activate
    user = User.find(params[:id])
    user.active = true
    user.save!
    redirect_to(:action => 'show', :id => user)
  end

  def deactivate
    user = User.find(params[:id])
    user.active = false
    user.save!
    redirect_to(:action => 'show', :id => user)
  end

  def destroy
    user = User.find(params[:id])
    flash[:notice] = "#{user.label} was successfully deleted."
    user.destroy
    redirect_to(:action => 'list')
  end
end
