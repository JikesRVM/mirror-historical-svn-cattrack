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

module CatTrack
  class SecurityError < StandardError
  end
end

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cattrack_session_id'

  self.check_environment

  # Turn of debug window displaying all assigns.
  # Can cause slowdown due massive tree of objects
  # that can be rendered.
  self.view_debug_display_assigns = true

  # Add filter for authentication and authorization
  before_filter :check_authorization

  # Add filter to setup audit log
  before_filter :setup_audit_log_data

  # export functions to helpers
  helper_method :current_user, :is_authenticated?

  protected

  helper_method :menu_name
  def menu_name
    nil
  end

  # overwrite this method if you only want to protect certain actions of the controller
  # example:
  #
  #  # don't protect the login and the about method
  #  def protect?
  #    if ['login', 'about'].include?(action_name)
  #       return false
  #    else
  #       return true
  #    end
  #  end
  def protect?
    false
  end

  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights
  # example:
  #
  #  # only allow nonbobs
  #  def authorize?
  #    current_user.name != "bob"
  #  end
  def authorized?
    true
  end

  # redirect unauthenticated user agent to login page when attempting to access resource requiring authentication
  def access_denied!
    if not is_authenticated?
      cookies.delete :cattrack_admin
      cookies.delete :cattrack_user
      render(:template => 'security/login_required', :status => 403)
    else
      render(:template => 'security/access_denied', :status => 403)
    end
    # TODO: should log or notify admin
  end

  def is_authenticated?
    !!current_user
  end

  # accesses the current user from the session.
  def current_user
    @current_user ||= session[:user_id] ? User.find_by_id_and_active(session[:user_id],true) : nil
  end

  # store the given user in the session.  overwrite this to set how
  # users are stored in the session.
  def current_user=(user)
    session[:user_id] = user.nil? ? nil : user.id
    @current_user = user
  end

  def check_authorization
    # skip login check if action is not protected
    return true unless protect?
    # check if user is logged in and authorized
    return true if (is_authenticated? and authorized?)

    # call overwriteable reaction to unauthorized access
    access_denied! and return false
  end

  def setup_audit_log_data
    AuditLog.current_user = current_user
    AuditLog.current_ip_address = request.remote_ip
  end

  # if an error occurs and it is a security error then redirect to access_denied page
  def rescue_action(e)
     if e.is_a?(CatTrack::SecurityError)
        access_denied!
     else
        super
     end
  end

  private

  # As we now allow '.' in the path we need to make sure caching handles this gracefully
  # Usually caching will not add page_cache_extension if '.' present. To get around this
  # assume that always add extension unless it matches one of types we know we generate.
  def self.page_cache_file(path)
    name = ((path.empty? || path == "/") ? "/index" : URI.unescape(path))
    last_part = name.split('/').last || name
    name << page_cache_extension unless (last_part =~ /\.txt$/)
    return name
  end
end

