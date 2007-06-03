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

class TestRunTest < Test::Unit::TestCase
  def test_label
    assert_equal('core', test_runs(:tr_1).label)
  end

  def test_parent_node
    assert_parent_node(test_runs(:tr_1), Host, 1)
  end

  def test_basic_load
    tc = test_runs(:tr_1)
    assert_equal( 1, tc.id )
    assert_equal( 1234, tc.revision )
    assert_equal( "2005-10-20T00:00:00Z", tc.occured_at.xmlschema )
    assert_equal( 1, tc.host_id )
    assert_equal( 1, tc.host.id )
    assert_equal( 1, tc.build_target.id )

    assert_equal( 3, tc.test_configurations.size )
    assert( tc.test_configuration_ids.include?(1) )
    assert( tc.test_configuration_ids.include?(2) )
    assert( tc.test_configuration_ids.include?(3) )

    assert_equal( 2, tc.build_runs.size )
    assert_equal( 1, tc.build_runs[0].id )
    assert_equal( 2, tc.build_runs[1].id )

    assert_equal( 'core', tc.name )

    assert_equal( 13, tc.successes.size )
    assert( tc.success_ids.include?(1) )
    assert_equal( 0, tc.failures.size )
    assert_equal( 0, tc.failures.collect {|t| t.id }.size )
    assert_equal( 0, tc.excludes.size )
    # Next line forces use of finder sql
    assert_equal( 0, tc.excludes.collect {|t| t.id }.size )

    assert_equal( 13, tc.test_cases.size )
    assert( tc.test_case_ids.include?(1) )
  end

  def self.attributes_for_new
    {:name => 'foo', :host_id => 1, :revision => 123, :occured_at => Time.now}
  end
  def self.non_null_attributes
    [:name, :host_id, :revision, :occured_at]
  end
  def self.str_length_attributes
    [[:name, 76]]
  end
  def self.bad_attributes
    [[:revision, -1]]
  end

  perform_basic_model_tests
end
