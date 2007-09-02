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

class Tdm::TestConfigurationTest < Test::Unit::TestCase
  def test_label
    assert_equal( Tdm::TestConfiguration.find(1).name, Tdm::TestConfiguration.find(1).label )
  end

  def test_parent_node
    assert_parent_node(Tdm::TestConfiguration.find(1), Tdm::BuildConfiguration, 1)
  end

  def test_basic_load
    tc = Tdm::TestConfiguration.find(1)
    assert_equal( 1, tc.id )
    assert_equal( 'prototype', tc.name )
    assert_equal( 1, tc.build_configuration_id )
    assert_equal( 1, tc.build_configuration.id )

    blank_params = { 'mode' => '', 'extra.args' => '' }
    assert_params_same(blank_params, tc.params)

    assert_equal( [1, 2], tc.group_ids )
    assert_equal( [1, 2, 4, 3], tc.success_ids )
    assert_equal( [1, 2, 4, 3], tc.test_case_execution_ids )
  end

  def test_success_rate
    assert_equal( "4/4", Tdm::TestConfiguration.find(1).success_rate )
  end

  def self.attributes_for_new
    {:name => 'foo', :build_configuration_id => 1}
  end
  def self.non_null_attributes
    [:name, :build_configuration_id]
  end
  def self.unique_attributes
    [[:build_configuration_id, :name]]
  end
  def self.str_length_attributes
    [[:name, 75]]
  end
  def self.bad_attributes
    [[:name, '.']]
  end

  perform_basic_model_tests
end
