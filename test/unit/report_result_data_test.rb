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

class ReportResultDataTest < Test::Unit::TestCase
  def test_basic_operation
    row = Olap::Query::SearchField.new(Olap::BuildConfigurationDimension, :name)
    column = Olap::Query::SearchField.new(Olap::TimeDimension, :da_of_week, :labels => [nil] | Time::RFC2822_DAY_NAME)
    data = [
    {'primary_dimension' => 'prototype', 'secondary_dimension' => '1', 'value' => '1.0' },
    {'primary_dimension' => 'prototype-opt', 'secondary_dimension' => '2', 'value' => '2.1' },
    ]
    d = ReportResultData.new('mysql', row, column, nil, data)
    assert_equal( 'mysql', d.sql )
    assert_equal( ['1', '2'], d.column_headers )
    assert_equal( ['prototype', 'prototype-opt'], d.row_headers )
    assert_equal( [['1.0', nil], [nil, '2.1']], d.tabular_data )
  end

  def test_larger_data_sets
    row = Olap::Query::SearchField.new(Olap::BuildConfigurationDimension, :name)
    column = Olap::Query::SearchField.new(Olap::TimeDimension, :da_of_week, :labels => [nil] | Time::RFC2822_DAY_NAME)
    data = [
    {'primary_dimension' => 'prototype', 'secondary_dimension' => '1', 'value' => '1.0' },
    {'primary_dimension' => 'prototype', 'secondary_dimension' => '2', 'value' => '1.1' },
    {'primary_dimension' => 'prototype-opt', 'secondary_dimension' => '1', 'value' => '2.0' },
    {'primary_dimension' => 'prototype-opt', 'secondary_dimension' => '2', 'value' => '2.1' },
    ]
    d = ReportResultData.new('mysql', row, column, nil, data)
    assert_equal( 'mysql', d.sql )
    assert_equal( ['1', '2'], d.column_headers )
    assert_equal( ['prototype', 'prototype-opt'], d.row_headers )
    assert_equal( [['1.0', '1.1'], ['2.0', '2.1']], d.tabular_data )

    data = [
    {'primary_dimension' => 'prototype', 'secondary_dimension' => '1', 'value' => '1.0' },
    {'primary_dimension' => 'prototype', 'secondary_dimension' => '2', 'value' => nil },
    {'primary_dimension' => 'prototype', 'secondary_dimension' => '3', 'value' => nil },
    {'primary_dimension' => 'prototype', 'secondary_dimension' => '4', 'value' => '1.4' },
    {'primary_dimension' => 'prototype-opt', 'secondary_dimension' => '1', 'value' => '2.0' },
    {'primary_dimension' => 'prototype-opt', 'secondary_dimension' => '2', 'value' => '2.1' },
    {'primary_dimension' => 'prototype-opt', 'secondary_dimension' => '3', 'value' => '2.2' },
    ]
    d = ReportResultData.new('mysql', row, column, nil, data)
    assert_equal( 'mysql', d.sql )
    assert_equal( ['1', '2', '3', '4'], d.column_headers )
    assert_equal( ['prototype', 'prototype-opt'], d.row_headers )
    assert_equal( [['1.0', nil, nil, '1.4'], ['2.0', '2.1', '2.2', nil]], d.tabular_data )
  end

  def test_basic_operation_with_multiple_values
    row = Olap::Query::SearchField.new(Olap::BuildConfigurationDimension, :name)
    column = Olap::Query::SearchField.new(Olap::TimeDimension, :da_of_week, :labels => [nil] | Time::RFC2822_DAY_NAME)
    data = [
    {'primary_dimension' => 'prototype', 'secondary_dimension' => '1', 'value1' => '1.0', 'value2' => 'a' },
    {'primary_dimension' => 'prototype-opt', 'secondary_dimension' => '2', 'value1' => '2.1', 'value2' => 'b' },
    ]
    d = ReportResultData.new('mysql', row, column, nil, data)
    assert_equal( 'mysql', d.sql )
    assert_equal( ['1', '2'], d.column_headers )
    assert_equal( ['prototype', 'prototype-opt'], d.row_headers )
    assert_equal( [[{'value1' => '1.0', 'value2' => 'a'}, nil], [nil, {'value1' => '2.1', 'value2' => 'b'}]], d.tabular_data )
  end

  def test_basic_operation_with_null_column
    row = Olap::Query::SearchField.new(Olap::BuildConfigurationDimension, :name)
    column = Olap::Query::SearchField.new(Olap::TimeDimension, :da_of_week, :labels => [nil] | Time::RFC2822_DAY_NAME)
    data = [
    {'primary_dimension' => 'prototype', 'secondary_dimension' => nil, 'value' => nil },
    {'primary_dimension' => 'prototype-opt', 'secondary_dimension' => '2', 'value' => '2.1' },
    ]
    d = ReportResultData.new('mysql', row, column, nil, data)
    assert_equal( 'mysql', d.sql )
    assert_equal( ['2'], d.column_headers )
    assert_equal( ['prototype', 'prototype-opt'], d.row_headers )
    assert_equal( [[nil], ['2.1']], d.tabular_data )
  end
end
