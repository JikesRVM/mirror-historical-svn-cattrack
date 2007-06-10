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
class Explorer::BaseController < ApplicationController
  self.force_no_cache

  protected
  def protect?
    true
  end

  private
  def menu_name
    (is_authenticated? and current_user.admin?) ? '/explorer/menu' : nil
  end
end