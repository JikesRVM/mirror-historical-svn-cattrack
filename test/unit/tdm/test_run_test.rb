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

class Tdm::TestRunTest < Test::Unit::TestCase
  def test_label
    assert_equal('core.1', Tdm::TestRun.find(1).label)
    tr = Tdm::TestRun.find(1)
    tr.variant = 'coreV'
    assert_equal('coreV.1', tr.label)
  end

  def test_parent_node
    assert_parent_node(Tdm::TestRun.find(1), Tdm::Host, 1)
  end

  def test_basic_load
    test_run = Tdm::TestRun.find(1)
    assert_equal( 1, test_run.id )
    assert_equal( 1234, test_run.revision )
    assert_equal( "2005-10-20T00:00:00Z", test_run.start_time.xmlschema )
    assert_equal( "2005-10-20T10:00:00Z", test_run.end_time.xmlschema )
    assert_equal( 'core', test_run.name )
    assert_equal( 'core', test_run.variant )
    assert_equal( 1, test_run.host_id )
    assert_equal( 1, test_run.host.id )
    assert_equal( 1, test_run.build_target.id )

    assert_equal( [1, 2], test_run.build_configuration_ids )

    # force both count and finder sqls ==> size + find
    #
    assert_equal( 13, test_run.successes.size )
    assert_equal( [1, 2, 4, 3, 5, 6, 8, 7, 13, 14, 17, 16, 15], test_run.success_ids )
    assert_equal( 13, test_run.test_case_executions.size )
    assert_equal( [1, 2, 4, 3, 5, 6, 8, 7, 13, 14, 17, 16, 15], test_run.test_case_execution_ids )
    assert_equal( 0, test_run.non_successes.size )
    assert_equal( [], test_run.non_success_ids )
  end

  def test_success_rate
    assert_equal( "13/13", Tdm::TestRun.find(1).success_rate )
  end

  def self.attributes_for_new
    {:name => 'foo', :variant => 'fooV', :host_id => 1, :revision => 123, :start_time => Time.now, :end_time => Time.now + 20}
  end
  def self.non_null_attributes
    [:name, :variant, :host_id, :revision, :start_time, :end_time]
  end
  def self.str_length_attributes
    [[:name, 75],[:variant, 75]]
  end
  def self.bad_attributes
    [[:revision, -1],[:name, '.'],[:variant, '.']]
  end

  perform_basic_model_tests

  def test_find_recent
    assert_equal([], Tdm::TestRun.find_recent.collect{|tr| tr.id})

    test_run1 = Tdm::TestRun.find(1)
    test_run1.start_time = Time.now
    test_run1.save!
    test_run2 = Tdm::TestRun.find(2)
    test_run2.start_time = Time.now
    test_run2.save!
    assert_equal([1, 2], Tdm::TestRun.find_recent.collect{|tr| tr.id})

    # Same variant/host
    test_run3 = clone_test_run(test_run1,3)
    test_run3.save!

    assert_equal([1, 2], Tdm::TestRun.find_recent.collect{|tr| tr.id})

    test_run3.variant = 'Foo'
    test_run3.save!

    assert_equal([1, 3, 2], Tdm::TestRun.find_recent.collect{|tr| tr.id})

    test_run3.variant = test_run1.variant
    test_run3.host = Tdm::Host.find_or_create_by_name('foo')
    test_run3.save!

    assert_equal([1, 3, 2], Tdm::TestRun.find_recent.collect{|tr| tr.id})

  end
end
