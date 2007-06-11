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

class TestCaseTest < Test::Unit::TestCase
  def test_label
    assert_equal( "TestClassLoading", test_cases(:tc_1).label )
  end

  def test_parent_node
    assert_parent_node(test_cases(:tc_1),Group,1)
  end

  def test_basic_load
    tc = test_cases(:tc_1)
    assert_equal( 1, tc.id )
    assert_equal( "TestClassLoading", tc.name )
    assert_equal( "TestClassLoading", tc.classname )
    assert_equal( "", tc.args )
    assert_equal( "/home/regression/peterd/jikesrvm/results/test/local/basic", tc.working_directory )
    assert_equal( "/home/regression/peterd/jikesrvm/dist/protottype-opt_linux-ia32/rvm -classpath ....", tc.command )
    assert_equal( "SUCCESS", tc.result )
    assert_equal( "", tc.result_explanation )
    assert_equal( 0, tc.exit_code )
    assert_equal( 457, tc.time )
    assert_equal( '1 times around the merry go round', tc.output )
    assert_equal( 1, tc.group_id )
    assert_equal( 1, tc.group.id )
    assert_equal( 0, tc.statistics.size )
  end

  def test_load_with_statistics
    tc = test_cases(:tc_17)
    assert_equal( 17, tc.id )
    assert_equal( "caffeinemark", tc.name )
    assert_equal( 1, tc.statistics.size )
    assert_equal( '54', tc.statistics['caffeinemark'] )
  end

  def test_new_with_output
    tc = TestCase.new(self.class.attributes_for_new)
    tc.save!
    tc2 = TestCase.find(tc.id)
    assert_equal( 'foooish!', tc2.output )
  end

  def test_new_with_success_and_result_explanation
    attrs = self.class.attributes_for_new
    attrs[:result_explanation] = 'foo'
    tc = TestCase.new(attrs)
    assert(!tc.valid?)
    assert_not_nil( tc.errors[:result_explanation] )
  end

  def self.attributes_for_new
    {
    :group_id => 1,
    :name => 'foo',
    :classname => 'Class foo',
    :args => '',
    :working_directory => '/home/peter',
    :command => 'rvm',
    :result => 'SUCCESS',
    :result_explanation => '',
    :exit_code => 0,
    :time => 142,
    :output => 'foooish!'
    }
  end
  def self.non_null_attributes
    [:group_id, :output, :name, :classname, :working_directory, :command, :result, :exit_code, :time]
  end
  def self.unique_attributes
    [[:group_id, :name]]
  end
  def self.str_length_attributes
    [[:name, 76],[:classname, 76],[:working_directory, 257],[:result, 16],[:result_explanation, 257]]
  end
  def self.bad_attributes
    [[:result, 'FOO'],[:time, -1],[:name, '.']]
  end

  perform_basic_model_tests
end
