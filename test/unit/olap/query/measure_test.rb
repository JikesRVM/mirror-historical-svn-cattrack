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

class Olap::Query::MeasureTest < Test::Unit::TestCase
  def test_label
    assert_equal( Olap::Query::Measure.find(1).name, Olap::Query::Measure.find(1).label )
  end

  def test_basic_load
    measure = Olap::Query::Measure.find(1)
    assert_equal( 1, measure.id )
    assert_equal( "Success Rate", measure.name )
    assert_equal( "case when :secondary_dimension IS NOT NULL then CAST(count(case when result_dimension.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 else NULL end", measure.sql )
    assert_equal( "result", measure.joins )
    assert_equal( "", measure.grouping )
  end

  def self.attributes_for_new
    {:name => 'foo', :sql => 'count(*)', :joins => '', :grouping => ''}
  end
  def self.non_null_attributes
    [:name, :sql, :joins, :grouping]
  end
  def self.unique_attributes
    [[:name]]
  end
  def self.str_length_attributes
    [[:name, 120], [:sql, 512], [:joins, 50], [:grouping, 50]]
  end

  perform_basic_model_tests

  def test_join_dimensions
    assert_equal( [Olap::ResultDimension], Olap::Query::Measure.find(1).join_dimensions )
    assert_equal( [], Olap::Query::Measure.new(self.class.attributes_for_new).join_dimensions )
  end
end
