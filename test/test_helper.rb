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
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = true
  self.display_invalid_content = true
  self.auto_validate = true

  fixtures ::OrderedTables

  DEFAULT_ASSIGNS = %w[ _cookies _flash _headers _params _request _response _session cookies flash headers params request response session action_name before_filter_chain_aborted db_rt_after_render db_rt_before_render ignore_missing_templates loggedin_user logger rendering_runtime request_origin template template_class template_root url user variables_added ]

  APP_DEFAULT_ASSIGNS = %w[ current_user ]

  def assert_normal_response(template_name, assigns_count = 0, flash_count = 0, response_code = :success)
    assert_response(response_code)
    assert_template(template_name)
    assert_equal(flash_count, flash.size, "Flash item count. Actual flash #{flash}") unless flash_count.nil?
    unless assigns_count.nil?
      user_assigns = assigns.select{|k, v| not DEFAULT_ASSIGNS.include?(k) and not APP_DEFAULT_ASSIGNS.include?(k)}.collect{|k,v|k}
      assert_equal(assigns_count, user_assigns.size, "Assigns item count. Actual assigns #{user_assigns.join(', ')}")
    end
  end

  def assert_new_record(key)
    assert_assigned(key)
    assert(assigns(key).new_record?, "Checking #{key} is a new record")
  end

  def assert_assigned(key)
    assert_not_nil(assigns(key), "Checking assigns for #{key}")
  end

  def assert_error_on(object, field)
    assert_assigned(object)
    assert_not_nil(assigns(object).errors, "Checking errors not nil for #{object}")
    assert_not_nil(assigns(object).errors[field], "Checking error on #{object} for field #{field}")
  end

  def assert_params_same(expected, actual)
    assert_equal( expected.size, actual.size )
    expected.each do |k, v|
      assert_equal( actual[k], v, "Testing Key #{k}" )
    end
  end

  def assert_parent_node(object, type = nil, id = nil)
    node = object.parent_node
    if type.nil?
      assert_nil(node)
    else
      assert_kind_of(type, node)
      assert_equal(id, node.id)
    end
  end
end
