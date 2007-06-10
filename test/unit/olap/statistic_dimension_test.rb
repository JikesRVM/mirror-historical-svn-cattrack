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

class Olap::StatisticDimensionTest < Test::Unit::TestCase
  def test_basic_load
    object = Olap::StatisticDimension.find(1)
    assert_equal( 1, object.id )
    assert_equal( 'time', object.name )
  end

  def self.attributes_for_new
    {:name => 'foo'}
  end
  def self.non_null_attributes
    [:name]
  end
  def self.str_length_attributes
    [[:name, 75]]
  end

  perform_basic_model_tests(:skip => [:destroy])
end
