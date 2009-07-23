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
require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/audit_log_controller'

class Admin::AuditLogController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Admin::AuditLogControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::AuditLogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_list
    get(:list, {}, session_data)
    assert_normal_response('list', 2)
    assert_assigned(:audit_logs)
    assert_assigned(:audit_log_pages)

    assert_equal([3, 1, 2], assigns(:audit_logs).collect {|r| r.id} )
    assert_equal(0, assigns(:audit_log_pages).current.offset)
    assert_equal(1, assigns(:audit_log_pages).page_count)
  end

  def test_list_with_query
    get(:list, {:q => 'user'}, session_data)
    assert_normal_response('list', 2)
    assert_assigned(:audit_logs)
    assert_assigned(:audit_log_pages)

    assert_equal([1], assigns(:audit_logs).collect {|r| r.id} )
    assert_equal(0, assigns(:audit_log_pages).current.offset)
    assert_equal(1, assigns(:audit_log_pages).page_count)
  end
end
