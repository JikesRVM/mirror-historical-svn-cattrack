require File.dirname(__FILE__) + '/../test_helper'
require 'test_case_controller'

class TestCaseController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class TestCaseControllerTest < Test::Unit::TestCase
  def setup
    @controller = TestCaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def model
    TestCase
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

  def test_show_output
    get(:show_output, {:id => 1}, session_data)
    assert_response(:success)
    assert_template(nil)
    assert_equal('text/plain; charset=utf-8',@response.headers['Content-Type'])
    assert_equal('1 times around the merry go round',@response.body)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
