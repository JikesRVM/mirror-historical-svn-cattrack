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
    test_run = TestRun.find(1)
    assert_equal( 1, test_run.id )
    assert_equal( 1234, test_run.revision )
    assert_equal( "2005-10-20T00:00:00Z", test_run.occured_at.xmlschema )
    assert_equal( 'core', test_run.name )
    assert_equal( 1, test_run.host_id )
    assert_equal( 1, test_run.host.id )
    assert_equal( 1, test_run.build_target.id )

    assert_equal( [1, 2], test_run.build_configurations.collect{|bc| bc.id}.sort )

    # force both count and finder sqls ==> size + find
    #
    assert_equal( 13, test_run.successes.size )
    assert_equal( true, test_run.successes.collect {|t| t.id }.include?(1) )
    assert_equal( 0, test_run.excluded.size )
    assert_equal( [], test_run.excluded.collect {|t| t.id } )
    assert_equal( 13, test_run.test_cases.size )
    assert_equal( true, test_run.test_cases.collect {|t| t.id }.include?(1) )

    # Used on summary screen
    assert_equal( 0, test_run.non_successes.size )
    assert_equal( [], test_run.non_successes.collect {|t| t.id } )
  end

  def test_success_rate
    assert_equal( "13/13", TestRun.find(1).success_rate )
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
