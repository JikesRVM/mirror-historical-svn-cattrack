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

class TestConfigurationTest < Test::Unit::TestCase
  def test_label
    assert_equal( 'prototype', test_configurations(:tc1_1).label )
  end

  def test_parent_node
    assert_parent_node(test_configurations(:tc1_1),TestRun,1)
  end

  def test_basic_load
    tc = test_configurations(:tc1_1)
    assert_equal( 1, tc.id )
    assert_equal( 'prototype', tc.name )
    assert_equal( 1, tc.build_run_id )
    assert_equal( 1, tc.build_run.id )

    blank_params = { 'mode' => '', 'extra.args' => '' }
    assert_params_same(blank_params, tc.params)

    assert_equal( 2, tc.groups.size )
    assert( tc.group_ids.include?(1) )
    assert( tc.group_ids.include?(2) )
  end

  def self.attributes_for_new
    {:name => 'foo', :build_run_id => 1}
  end
  def self.non_null_attributes
    [:name, :build_run_id]
  end
  def self.unique_attributes
    [[:build_run_id, :name]]
  end
  def self.str_length_attributes
    [[:name, 75]]
  end

  perform_basic_model_tests
end
