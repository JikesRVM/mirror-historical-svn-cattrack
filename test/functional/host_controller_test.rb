require File.dirname(__FILE__) + '/../test_helper'
require 'host_controller'

class HostController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class HostControllerTest < Test::Unit::TestCase
  def setup
    @controller = HostController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def session_data
    {:user_id => 1}
  end

  def test_show
    id = 1
    get(:show, {:id => id}, session_data)
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
