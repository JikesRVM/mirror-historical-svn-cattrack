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

class SummarizerTest < Test::Unit::TestCase
  def test_label
    assert_equal( Summarizer.find(1).name, Summarizer.find(1).label )
  end

  def test_basic_load
    summarizer = Summarizer.find(1)
    assert_equal( 1, summarizer.id )
    assert_equal( 'Success Rate by Build Configuration by Day of Week', summarizer.name )
    assert_equal( '', summarizer.description )
    assert_equal( 'build_configuration_name', summarizer.primary_dimension )
    assert_equal( 'time_day_of_week', summarizer.secondary_dimension )
    assert_equal( 'success_rate', summarizer.function )
    assert_equal( 'success_rate', summarizer.function )
  end

  def self.attributes_for_new
    {:name => 'foo', :description => '', :primary_dimension => 'build_target_name', :secondary_dimension => 'time_day_of_week', :function => 'success_rate'}
  end
  def self.non_null_attributes
    [:name, :description, :primary_dimension, :secondary_dimension, :function]
  end
  def self.unique_attributes
    [[:name]]
  end
  def self.str_length_attributes
    [[:name, 120],[:description,256],[:primary_dimension,256],[:secondary_dimension,256],[:function,256]]
  end

  perform_basic_model_tests
end
