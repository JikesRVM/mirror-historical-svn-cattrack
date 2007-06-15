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

class Tdm::GroupTest < Test::Unit::TestCase
  def test_label
    assert_equal( "basic", Tdm::Group.find(1).label )
  end

  def test_parent_node
    assert_parent_node(Tdm::Group.find(1),Tdm::TestConfiguration,1)
  end

  def test_basic_load
    group = Tdm::Group.find(1)
    assert_equal( 1, group.id )
    assert_equal( "basic", group.name )
    assert_equal( 1, group.test_configuration_id )
    assert_equal( 1, group.test_configuration.id )
    assert_equal( [1 , 2], group.test_case_ids )
    assert_equal( [], group.excluded_ids )
    assert_equal( [1 , 2], group.success_ids )
  end

  def test_success_rate
    assert_equal( "2/2", Tdm::Group.find(1).success_rate )
    test_case = Tdm::TestCase.new
    test_case.attributes = Tdm::TestCase.find(1).attributes
    test_case.name = 'X'
    test_case.result = 'EXCLUDED'
    test_case.output = "X"
    test_case.save!
    assert_equal( "2/2 (1 excluded)", Tdm::Group.find(1).success_rate )
  end

  def self.attributes_for_new
    {:name => 'foo', :test_configuration_id => 1 }
  end
  def self.non_null_attributes
    [:name, :test_configuration_id]
  end
  def self.unique_attributes
    [[:test_configuration_id,:name]]
  end
  def self.str_length_attributes
    [[:name, 76]]
  end
  def self.bad_attributes
    [[:name, '.']]
  end

  perform_basic_model_tests
end