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

class DataViewTest < Test::Unit::TestCase
  SUCCESS_FUNCTION = "case when time_dimensions.day_of_week IS NOT NULL then CAST(count(case when result_dimensions.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 else NULL end"
  def test_basic_load
    data_view = DataView.find(1)
    assert_equal( 1, data_view.id )
    assert_equal( 1, data_view.filter_id )
    assert_equal( 1, data_view.filter.id )
    assert_equal( 1, data_view.summarizer_id )
    assert_equal( 1, data_view.summarizer.id )
    assert_equal( 1, data_view.data_presentation_id )
    assert_equal( 1, data_view.data_presentation.id )
  end

  def self.attributes_for_new
    {:filter_id => 1, :summarizer_id => 1, :data_presentation_id => 1}
  end
  def self.non_null_attributes
    [:filter_id, :summarizer_id, :data_presentation_id]
  end

  perform_basic_model_tests

  def blank_data_view
    data_view = DataView.new
    data_view.filter = Filter.new
    data_view.filter.name = 'X'
    data_view.filter.description = ''
    data_view.summarizer = Summarizer.new
    data_view.summarizer.name = 'X'
    data_view.summarizer.description = ''
    data_view.data_presentation = DataPresentation.new
    data_view.data_presentation.name = 'X'
    data_view
  end

  def check_data_view(data_view)
    assert_equal(true, data_view.filter.valid?, data_view.filter.errors.to_xml)
    assert_equal(true, data_view.summarizer.valid?, data_view.summarizer.errors.to_xml)
    #assert_equal(true, data_view.valid?, data_view.errors.to_xml)
  end

  def do_search(data_view)
    check_data_view(data_view)
    data_view.perform_search
  end

  def test_sql_with_no_filter
    data_view = blank_data_view
    data_view.summarizer.primary_dimension = 'build_configuration_name'
    data_view.summarizer.secondary_dimension = 'time_day_of_week'
    data_view.summarizer.function = 'success_rate'

    results = do_search(data_view)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimensions.name AS primary_dimension,
 time_dimensions.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 LEFT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE 1 = 1
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_sql_with_non_overlapping_filter
    data_view = blank_data_view
    data_view.filter.build_target_arch = 'ia32'
    data_view.summarizer.primary_dimension = 'build_configuration_name'
    data_view.summarizer.secondary_dimension = 'time_day_of_week'
    data_view.summarizer.function = 'success_rate'

    results = do_search(data_view)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimensions.name AS primary_dimension,
 time_dimensions.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN build_target_dimensions ON result_facts.build_target_id = build_target_dimensions.id
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 LEFT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE build_target_dimensions.arch = 'ia32'
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_sql_with_filter_overlapping_column
    data_view = blank_data_view
    data_view.filter.time_week = 2
    data_view.summarizer.primary_dimension = 'build_configuration_name'
    data_view.summarizer.secondary_dimension = 'time_day_of_week'
    data_view.summarizer.function = 'success_rate'

    results = do_search(data_view)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimensions.name AS primary_dimension,
 time_dimensions.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 LEFT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE time_dimensions.week = 2
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_sql_with_filter_overlapping_row
    data_view = blank_data_view
    data_view.filter.build_configuration_runtime_compiler = 'opt'
    data_view.summarizer.primary_dimension = 'build_configuration_name'
    data_view.summarizer.secondary_dimension = 'time_day_of_week'
    data_view.summarizer.function = 'success_rate'

    results = do_search(data_view)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimensions.name AS primary_dimension,
 time_dimensions.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 LEFT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE build_configuration_dimensions.runtime_compiler = 'opt'
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_sql_with_filter_overlapping_column
    data_view = blank_data_view
    data_view.filter.time_week = 2
    data_view.summarizer.primary_dimension = 'build_configuration_name'
    data_view.summarizer.secondary_dimension = 'time_day_of_week'
    data_view.summarizer.function = 'success_rate'

    results = do_search(data_view)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimensions.name AS primary_dimension,
 time_dimensions.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 LEFT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE time_dimensions.week = 2
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_sql_with_filter_overlapping_function
    data_view = blank_data_view
    data_view.filter.result_name = 'SUCCESS'
    data_view.summarizer.primary_dimension = 'build_configuration_name'
    data_view.summarizer.secondary_dimension = 'time_day_of_week'
    data_view.summarizer.function = 'success_rate'

    results = do_search(data_view)

    assert_equal(<<END_SQL, results.sql)
SELECT
 build_configuration_dimensions.name AS primary_dimension,
 time_dimensions.day_of_week AS secondary_dimension,
 #{SUCCESS_FUNCTION}
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 LEFT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE result_dimensions.name = 'SUCCESS'
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_perform_summarizer
    data_view = blank_data_view
    data_view.filter.result_name = 'SUCCESS'
    data_view.summarizer.primary_dimension = 'build_configuration_name'
    data_view.summarizer.secondary_dimension = 'time_day_of_week'
    data_view.summarizer.function = 'success_rate'

    results = do_search(data_view)
    assert_not_nil(results)
    assert_not_nil(results.row)
    assert_not_nil(results.column)
    assert_not_nil(results.function)
    assert_not_nil(results.data)
    assert_equal(BuildConfigurationDimension, results.row.dimension)
    assert_equal(:name, results.row.name)
    assert_equal(TimeDimension, results.column.dimension)
    assert_equal(:day_of_week, results.column.name)
    assert_equal([ResultDimension], results.function.dimensions)
  end
end
