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
require File.dirname(__FILE__) + '/../test_helper'
require 'application'

class ApplicationController
  def index
    render :text => '', :layout => false
  end

  def raise_error
    raise CatTrack::SecurityError
  end

  def self.pcf(path)
    page_cache_file(path)
  end
end

class ApplicationControllerTest < Test::Unit::TestCase
  def setup
    @controller = ApplicationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  self.auto_validate_excludes = [:test_allow_unauthenticated_access, :test_access_allowed_when_authenticated, :test_audit_log_setup]

  def test_allow_unauthenticated_access
    get(:index, {}, {})
    assert_response(:success)
    assert_flash_count(0)
    assert_equal( false, @controller.send(:is_authenticated?) )
    assert_nil( @controller.send(:current_user) )
  end

  def test_access_allowed_when_authenticated
    get(:index, {}, {:user_id => 1})
    assert_response(:success)
    assert_flash_count(0)
    assert_equal( true, @controller.send(:is_authenticated?) )
    assert_not_nil( @controller.send(:current_user) )
    assert_equal( 1, @controller.send(:current_user).id )
  end

  def test_audit_log_setup
    AuditLog.current_user = nil
    AuditLog.current_ip_address = nil
    @request.env['HTTP_CLIENT_IP'] = '1.2.3.4'
    get(:index, {}, {:user_id => 1})
    assert_response(:success)
    assert_flash_count(0)
    assert_equal( 1, AuditLog.current_user.id )
    assert_equal( '1.2.3.4', AuditLog.current_ip_address )
  end

  def test_access_denied_with_authenticated
    get(:raise_error, {}, {:user_id => 1})
    assert_normal_response('access_denied', 0, 0, 403)
  end

  def test_access_denied_with_unauthenticated
    get(:raise_error, {}, {})
    assert_normal_response('login_required', 0, 0, 403)
  end


  def test_page_cache_file
    assert_equal('/index.html', ApplicationController.pcf('/'))
    assert_equal('/results/excalibur.watson.ibm.com/core.36/production/Measure_Compilation_Opt_0/SPECjvm98/_200.check/Output.txt', ApplicationController.pcf('/results/excalibur.watson.ibm.com/core.36/production/Measure_Compilation_Opt_0/SPECjvm98/_200.check/Output.txt'))
    assert_equal('/results/excalibur.watson.ibm.com/core.36/production/Measure_Compilation_Opt_0/SPECjvm98/_200.check.html', ApplicationController.pcf('/results/excalibur.watson.ibm.com/core.36/production/Measure_Compilation_Opt_0/SPECjvm98/_200.check'))
  end
end
