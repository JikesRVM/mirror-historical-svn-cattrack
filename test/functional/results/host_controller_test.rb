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
    id = 1
    get(:show, {:host_name => 'skunk'}, session_data)
    assert_response(:success)
    assert_template('show')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_not_nil(assigns(:record))
    assert_equal(id, assigns(:record).id)
  end

  def test_list
    get(:list, {}, session_data)
    assert_response(:success)
    assert_template('list')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    assert_not_nil(assigns(:records))

    assert_equal(2, assigns(:records).size)
    assert_not_nil(assigns(:record_pages))
    assert_equal(0, assigns(:record_pages).current.offset)
    assert_equal(1, assigns(:record_pages).page_count)
    assert_equal([2, 1], assigns(:records).collect {|r| r.id} )
  end
end