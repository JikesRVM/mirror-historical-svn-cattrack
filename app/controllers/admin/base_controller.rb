class Admin::BaseController < ApplicationController
  before_filter :verify_admin

  self.force_no_cache

  protected
  def protect?
    true
  end

  private
  def menu_name
    (is_authenticated? and current_user.admin?) ? '/admin/menu' : nil
  end

  def verify_admin
    raise AuthenticatedSystem::SecurityError unless current_user.admin?
  end
end
