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

class Tdm::TestCaseTest < Test::Unit::TestCase
  def test_label
    assert_equal( Tdm::TestCase.find(1).name, Tdm::TestCase.find(1).label )
  end

  def test_parent_node
    assert_parent_node(Tdm::TestCase.find(1),Tdm::Group,1)
  end

  def test_basic_load
    tc = Tdm::TestCase.find(1)
    assert_equal( 1, tc.id )
    assert_equal( "TestClassLoading", tc.name )
    assert_equal( "cd /home/regression/peterd/jikesrvm/results/test/local/basic && /home/regression/peterd/jikesrvm/dist/protottype-opt_linux-ia32/rvm -classpath ....", tc.command )
    assert_equal( 1, tc.group_id )
    assert_equal( 1, tc.group.id )
    assert_equal( 1, tc.test_case_executions.size )
  end

  def self.attributes_for_new
    {
    :group_id => 1,
    :name => 'foo',
    :command => 'rvm'
    }
  end
  def self.non_null_attributes
    [:group_id, :name, :command]
  end
  def self.unique_attributes
    [[:group_id, :name]]
  end
  def self.str_length_attributes
    [[:name, 75]]
  end
  def self.bad_attributes
    [[:name, '*']]
  end

  perform_basic_model_tests
end
