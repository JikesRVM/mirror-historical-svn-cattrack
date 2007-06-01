require File.dirname(__FILE__) + '/../test_helper'
require 'report_controller'

class ReportController
  # Re-raise errors caught by the controller.
  def rescue_action(e)
    raise e
  end
end

class ReportControllerTest < Test::Unit::TestCase
  def setup
    @controller = ReportController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_list
    get(:list, {}, session_data)
    assert_response(:success)
    assert_template('list')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])

    assert_not_nil(assigns(:search))

    assert_equal(['helm','skunk'], assigns(:host_names) )
    assert_equal(['core'], assigns(:test_run_names) )
    assert_equal(['ia32_linux'], assigns(:build_target_names) )
    assert_equal(['ia32'], assigns(:build_target_arches) )
    assert_equal(['32'], assigns(:build_target_address_sizes) )
    assert_equal(['Linux'], assigns(:build_target_operating_systems) )

  end
end
