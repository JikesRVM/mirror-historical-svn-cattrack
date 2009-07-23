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
require 'admin/sysinfo_controller'

class Admin::SysinfoController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Admin::SysinfoControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::SysinfoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    get(:show, {}, {:user_id => 1})
    assert_normal_response('show')
  end

  def test_purge_stale_sessions
    # Need to specify sql otherwise rails overides updated_on
    sql = <<SQL
    INSERT INTO sessions ("created_on", "updated_on", "sessid", "data") VALUES('1970-01-01 10:00:00.000000', '1970-01-01 10:00:00.000000', 'abcde', '')
SQL
    ActiveRecord::Base.connection.execute(sql)
    assert_equal(1, CGI::Session::ActiveRecordStore::Session.count)
    purge_log
    post(:purge_stale_sessions, {}, {:user_id => 1})
    assert_redirected_to(:action => 'show')
    assert_flash_count(0)
    assert_assigns_count(0)
    assert_equal(0, CGI::Session::ActiveRecordStore::Session.count)
    assert_logs([["sys.purge_stale_sessions", '']], 1)
  end
end
