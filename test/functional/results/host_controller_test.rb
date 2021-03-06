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
require 'results/host_controller'

class Results::HostController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class Results::HostControllerTest < Test::Unit::TestCase
  def setup
    @controller = Results::HostController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_show
    host = Tdm::Host.find(1)
    get(:show, {:host_name => host.name}, session_data)
    assert_normal_response('show', 2)
    assert_assigned(:host)
    assert_assigned(:variants)
    assert_equal( host.id, assigns(:host).id )
    assert_equal( 1, assigns(:variants).size )
    assert_equal( "core", assigns(:variants)[0])
  end

  def test_list
    get(:list, {}, session_data)
    assert_normal_response('list', 2)
    assert_assigned(:records)
    assert_assigned(:record_pages)
    assert_equal([2, 1], assigns(:records).collect {|r| r.id} )
    assert_equal(0, assigns(:record_pages).current.offset)
    assert_equal(1, assigns(:record_pages).page_count)
  end
end
