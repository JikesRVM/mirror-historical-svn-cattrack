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
require File.dirname(__FILE__) + '/../../../test_helper'

class Olap::Query::PresentationTest < Test::Unit::TestCase
  def test_label
    assert_equal( Olap::Query::Presentation.find(1).name, Olap::Query::Presentation.find(1).label )
  end

  def test_basic_load
    presentation = Olap::Query::Presentation.find(1)
    assert_equal( 1, presentation.id )
    assert_equal( 'Pivot Table', presentation.name )
    assert_equal( 'pivot', presentation.key )
    assert_equal( [1, 2, 3, 4, 5], presentation.measure_ids )
  end

  def self.attributes_for_new
    {:name => 'foo', :key => 'f'}
  end
  def self.non_null_attributes
    [:name, :key]
  end
  def self.unique_attributes
    [[:name], [:key]]
  end
  def self.str_length_attributes
    [[:name, 120], [:key, 20]]
  end

  perform_basic_model_tests
end
