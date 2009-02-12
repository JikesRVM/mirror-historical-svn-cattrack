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

class Tdm::TestCaseExecutionTest < Test::Unit::TestCase
  def test_label
    assert_equal( Tdm::TestCaseExecution.find(1).name, Tdm::TestCaseExecution.find(1).label )
  end

  def test_basic_load
    tc = Tdm::TestCaseExecution.find(1)
    assert_equal( 1, tc.id )
    assert_equal( "1", tc.name )
    assert_equal( "SUCCESS", tc.result )
    assert_equal( "", tc.result_explanation )
    assert_equal( 0, tc.exit_code )
    assert_equal( 457, tc.time )
    assert_equal( '1 times around the merry go round', tc.output )
    assert_equal( 1, tc.test_case_id )
    assert_equal( 1, tc.test_case.id )
    assert_equal( 0, tc.statistics.size )
    assert_equal( 0, tc.num_stats.size )
  end

  def test_load_with_statistics
    tc = Tdm::TestCaseExecution.find(17)
    assert_equal( 17, tc.id )
    assert_equal( 1, tc.statistics.size )
    assert_equal( '54', tc.statistics['caffeinemark'] )
    assert_equal( '54', tc.num_stats['caffeinemark_numerical'] )
  end

  def test_new_with_output
    tc = Tdm::TestCaseExecution.new(self.class.attributes_for_new)
    tc.save!
    tc2 = Tdm::TestCaseExecution.find(tc.id)
    assert_equal('foooish!', tc2.output )
  end

  def test_new_with_success_and_result_explanation
    attrs = self.class.attributes_for_new
    attrs[:result_explanation] = 'foo'
    tc = Tdm::TestCaseExecution.new(attrs)
    assert(!tc.valid?)
    assert_not_nil(tc.errors[:result_explanation])
  end

  def self.attributes_for_new
    {
    :test_case_id => 1,
    :name => 'X',
    :result => 'SUCCESS',
    :result_explanation => '',
    :exit_code => 0,
    :time => 142,
    :output => 'foooish!'
    }
  end
  def self.non_null_attributes
    [:test_case_id, :output, :name, :result, :exit_code, :time]
  end
  def self.unique_attributes
    [[:test_case_id, :name]]
  end
  def self.str_length_attributes
    [[:name, 75],[:result, 15],[:result_explanation, 256]]
  end
  def self.bad_attributes
    [[:result, 'FOO'],[:time, -1],[:name, '*']]
  end

  perform_basic_model_tests
end
