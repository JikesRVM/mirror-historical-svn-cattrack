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
require File.dirname(__FILE__) + '/../test_helper'
require 'application'

class ApplicationController
  def index
    render :text => '', :layout => false
  end

  def raise_error
    raise CatTrack::SecurityError
  end
end

class ApplicationControllerTest < Test::Unit::TestCase
  def setup
    @controller = ApplicationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  self.auto_validate_excludes = [:test_allow_unauthenticated_access]

  def test_allow_unauthenticated_access
    get(:index, {}, {})
    assert_response(:success)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_access_denied_with_authenticated
    get(:raise_error, {}, {:user_id => 1})
    assert_response(403)
    assert_template('access_denied')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_access_denied_with_unauthenticated
    get(:raise_error, {}, {})
    assert_response(403)
    assert_template('login_required')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end
