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

class Olap::Query::QueryTest < Test::Unit::TestCase
  SUCCESS_FUNCTION = "case when time_dimension.day_of_week IS NOT NULL then CAST(count(case when result_dimension.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 else NULL end"

  def test_label
    assert_equal( Olap::Query::Query.find(1).name, Olap::Query::Query.find(1).label )
  end

  def test_basic_load
    summarizer = Olap::Query::Query.find(1)
    assert_equal( 1, summarizer.id )
    assert_equal( 'Success Rate by Build Configuration by Day of Week', summarizer.name )
    assert_equal( '', summarizer.description )
    assert_equal( 'build_configuration_name', summarizer.primary_dimension )
    assert_equal( 'time_day_of_week', summarizer.secondary_dimension )
    assert_equal( 1, summarizer.measure_id )
    assert_equal( 1, summarizer.measure.id )
    assert_equal( 1, summarizer.filter_id )
    assert_equal( 1, summarizer.filter.id )
    assert_equal( 2, summarizer.presentation_id )
    assert_equal( 2, summarizer.presentation.id )
  end

  def self.attributes_for_new
    {:name => 'foo', :description => '', :primary_dimension => 'build_target_name', :secondary_dimension => 'time_day_of_week', :filter_id => 1, :measure_id => 1, :presentation_id => 3}
  end
  def self.non_null_attributes
    [:name, :description, :primary_dimension, :secondary_dimension, :filter_id, :measure_id, :presentation_id]
  end
  def self.unique_attributes
    [[:name]]
  end
  def self.str_length_attributes
    [[:name, 120],[:description,256],[:primary_dimension,256],[:secondary_dimension,256]]
  end

  perform_basic_model_tests

  def new_query
    query = Olap::Query::Query.new
    query.name = '*'
    query.description = ''
    query.filter = Olap::Query::Filter.new
    query.filter.name = '*'
    query.filter.description = ''
    query.presentation = Olap::Query::Presentation.new
    query.presentation.name = '*'
    query.primary_dimension = 'build_configuration_name'
    query.secondary_dimension = 'time_day_of_week'
    query.measure = Olap::Query::Measure.find(1)
    query
  end

  def check_query(query)
    assert_equal(true, query.filter.valid?, query.filter.errors.to_xml)
    #assert_equal(true, query.valid?, query.errors.to_xml)
  end

  def do_search(query)
    check_query(query)
    query.perform_search
  end

  def test_sql_with_no_filter
    query = new_query

    results = do_search(query)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimension.name AS primary_dimension,
 time_dimension.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimension ON result_facts.result_id = result_dimension.id
 RIGHT JOIN build_configuration_dimension ON result_facts.build_configuration_id = build_configuration_dimension.id
 LEFT JOIN time_dimension ON result_facts.time_id = time_dimension.id
WHERE 1 = 1
GROUP BY build_configuration_dimension.name, time_dimension.day_of_week
ORDER BY build_configuration_dimension.name, time_dimension.day_of_week
END_SQL
  end

  def test_sql_with_non_overlapping_filter
    query = new_query
    query.filter.build_target_arch = 'ia32'

    results = do_search(query)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimension.name AS primary_dimension,
 time_dimension.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN build_target_dimension ON result_facts.build_target_id = build_target_dimension.id
 LEFT JOIN result_dimension ON result_facts.result_id = result_dimension.id
 RIGHT JOIN build_configuration_dimension ON result_facts.build_configuration_id = build_configuration_dimension.id
 LEFT JOIN time_dimension ON result_facts.time_id = time_dimension.id
WHERE build_target_dimension.arch = 'ia32'
GROUP BY build_configuration_dimension.name, time_dimension.day_of_week
ORDER BY build_configuration_dimension.name, time_dimension.day_of_week
END_SQL
  end

  def test_sql_with_filter_overlapping_column
    query = new_query
    query.filter.time_week = 2

    results = do_search(query)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimension.name AS primary_dimension,
 time_dimension.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimension ON result_facts.result_id = result_dimension.id
 RIGHT JOIN build_configuration_dimension ON result_facts.build_configuration_id = build_configuration_dimension.id
 LEFT JOIN time_dimension ON result_facts.time_id = time_dimension.id
WHERE time_dimension.week = 2
GROUP BY build_configuration_dimension.name, time_dimension.day_of_week
ORDER BY build_configuration_dimension.name, time_dimension.day_of_week
END_SQL
  end

  def test_sql_with_filter_overlapping_row
    query = new_query
    query.filter.build_configuration_runtime_compiler = 'opt'

    results = do_search(query)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimension.name AS primary_dimension,
 time_dimension.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimension ON result_facts.result_id = result_dimension.id
 RIGHT JOIN build_configuration_dimension ON result_facts.build_configuration_id = build_configuration_dimension.id
 LEFT JOIN time_dimension ON result_facts.time_id = time_dimension.id
WHERE build_configuration_dimension.runtime_compiler = 'opt'
GROUP BY build_configuration_dimension.name, time_dimension.day_of_week
ORDER BY build_configuration_dimension.name, time_dimension.day_of_week
END_SQL
  end

  def test_sql_with_filter_overlapping_column
    query = new_query
    query.filter.time_week = 2

    results = do_search(query)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimension.name AS primary_dimension,
 time_dimension.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimension ON result_facts.result_id = result_dimension.id
 RIGHT JOIN build_configuration_dimension ON result_facts.build_configuration_id = build_configuration_dimension.id
 LEFT JOIN time_dimension ON result_facts.time_id = time_dimension.id
WHERE time_dimension.week = 2
GROUP BY build_configuration_dimension.name, time_dimension.day_of_week
ORDER BY build_configuration_dimension.name, time_dimension.day_of_week
END_SQL
  end

  def test_sql_with_filter_overlapping_measure
    query = new_query
    query.filter.result_name = 'SUCCESS'

    results = do_search(query)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimension.name AS primary_dimension,
 time_dimension.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimension ON result_facts.result_id = result_dimension.id
 RIGHT JOIN build_configuration_dimension ON result_facts.build_configuration_id = build_configuration_dimension.id
 LEFT JOIN time_dimension ON result_facts.time_id = time_dimension.id
WHERE result_dimension.name = 'SUCCESS'
GROUP BY build_configuration_dimension.name, time_dimension.day_of_week
ORDER BY build_configuration_dimension.name, time_dimension.day_of_week
END_SQL
  end

  def test_perform
    query = new_query
    query.filter.result_name = 'SUCCESS'

    results = do_search(query)
    assert_not_nil(results)
    assert_not_nil(results.row)
    assert_not_nil(results.column)
    assert_not_nil(results.measure)
    assert_not_nil(results.data)
    assert_equal(Olap::BuildConfigurationDimension, results.row.dimension)
    assert_equal(:name, results.row.name)
    assert_equal(Olap::TimeDimension, results.column.dimension)
    assert_equal(:day_of_week, results.column.name)
    assert_equal([Olap::ResultDimension], results.measure.join_dimensions)
  end

end
