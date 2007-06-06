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

class FilterTest < Test::Unit::TestCase
  def test_label
    assert_equal( Filter.find(1).name, Filter.find(1).label )
  end

  def test_basic_load
    filter = Filter.find(1)
    assert_equal( 1, filter.id )
    assert_equal( "Last Week", filter.name )
    assert_params_same({'time_from' => '-1w'}, filter.params)

    filter = Filter.find(2)
    assert_equal( 2, filter.id )
    assert_equal( "Core Configurations", filter.name )
    assert_equal(1, filter.params.size)

    assert_equal(["development", "production", "prototype", "prototype-opt"], filter.params['build_configuration_name'].sort)
  end

  def self.attributes_for_new
    {:name => 'foo'}
  end
  def self.non_null_attributes
    [:name]
  end
  def self.unique_attributes
    [[:name]]
  end
  def self.str_length_attributes
    [[:name, 75]]
  end

  perform_basic_model_tests
end
