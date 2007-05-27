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
  verify :method => :get, :only => [:show,:list], :redirect_to => {:action => :index}
  verify :method => :post, :only => [:enable_admin, :disable_admin, :activate, :deactivate, :add_uploader_permission, :remove_uploader_permission], :redirect_to => {:action => :index}

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
    @user = User.find(params[:id])
    @user.admin = true
    @user.save!
    redirect_to(:action => 'show', :id => @user)
  end

  def disable_admin
    @user = User.find(params[:id])
    @user.admin = false
    @user.save!
    redirect_to(:action => 'show', :id => @user)
  end

  def activate
    @user = User.find(params[:id])
    @user.active = true
    @user.save!
    redirect_to(:action => 'show', :id => @user)
  end

  def deactivate
    @user = User.find(params[:id])
    @user.active = false
    @user.save!
    redirect_to(:action => 'show', :id => @user)
  end

  def add_uploader_permission
    @user = User.find(params[:id])
    @user.uploader = true
    @user.save!
    redirect_to(:action => 'show', :id => @user)
  end

  def remove_uploader_permission
    @user = User.find(params[:id])
    @user.uploader = false
    @user.save!
    redirect_to(:action => 'show', :id => @user)
  end

  def destroy
    @user = User.find(params[:id])
    if @user.test_runs.size > 0
      flash[:alert] = "#{@user.label} could not be deleted as they have uploaded #{@user.test_runs.size} test runs. Remove the test runs or deactivate the account instead."
      redirect_to(:action => 'show', :id => @user.id)
      return
    end
    flash[:notice] = "#{@user.label} was successfully deleted."
    @user.destroy
    redirect_to(:action => 'list')
  end
end
