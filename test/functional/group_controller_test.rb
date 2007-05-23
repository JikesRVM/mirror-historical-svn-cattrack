require File.dirname(__FILE__) + '/../test_helper'
require 'group_controller'

class GroupController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class GroupControllerTest < Test::Unit::TestCase
  def setup
    @controller = GroupController.new
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
end
