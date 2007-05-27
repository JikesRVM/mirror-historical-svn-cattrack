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

class TimeDimensionTest < Test::Unit::TestCase
  def test_basic_load
    object = TimeDimension.find(1)
    assert_equal( 1, object.id )
    assert_equal( 2007, object.year )
    assert_equal( 1, object.month )
    assert_equal( 1, object.week )
    assert_equal( 1, object.day_of_year )
    assert_equal( 1, object.day_of_month )
    assert_equal( 1, object.day_of_week )
  end

  def self.attributes_for_new
    {:year => 2007, :month => 10, :week => 22, :day_of_year => 2, :day_of_month => 2, :day_of_week => 2}
  end
  def self.non_null_attributes
    [:year, :month, :week, :day_of_year, :day_of_month, :day_of_week]
  end
  def self.bad_attributes
    [[:year, 1977],[:month, 22],[:week, -22],[:day_of_year, -1],[:day_of_month, -22],[:day_of_week, -3]]
  end

  perform_basic_model_tests(:skip => [:destroy])
end
