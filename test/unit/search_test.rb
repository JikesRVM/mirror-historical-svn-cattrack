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
require 'search'

class SearchTest < Test::Unit::TestCase
  def test_to_sql2_with_no_filter
    filter = Filter.new
    filter.name = 'X'
    filter.description = ''
    assert_equal(true, filter.valid?, filter.errors.to_xml)

    summarizer = Summarizer.new
    summarizer.name = 'X'
    summarizer.description = ''
    summarizer.primary_dimension = 'build_configuration_name'
    summarizer.secondary_dimension = 'time_day_of_week'
    summarizer.function = 'success_rate'
    assert_equal(true, summarizer.valid?, summarizer.errors.to_xml)

    assert_equal(<<END_SQL, Search.new.perform_search(filter, summarizer).sql)
SELECT
 build_configuration_dimensions.name as row,
 time_dimensions.day_of_week as column,
 CAST(count(case when result_dimensions.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 as value
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 RIGHT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE 1 = 1
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_to_sql2_with_non_overlapping_filter
    filter = Filter.new
    filter.name = 'X'
    filter.description = ''
    filter.build_target_arch = 'ia32'
    assert_equal(true, filter.valid?, filter.errors.to_xml)

    summarizer = Summarizer.new
    summarizer.name = 'X'
    summarizer.description = ''
    summarizer.primary_dimension = 'build_configuration_name'
    summarizer.secondary_dimension = 'time_day_of_week'
    summarizer.function = 'success_rate'
    assert_equal(true, summarizer.valid?, summarizer.errors.to_xml)

    assert_equal(<<END_SQL, Search.new.perform_search(filter, summarizer).sql)
SELECT
 build_configuration_dimensions.name as row,
 time_dimensions.day_of_week as column,
 CAST(count(case when result_dimensions.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 as value
FROM result_facts
 LEFT JOIN build_target_dimensions ON result_facts.build_target_id = build_target_dimensions.id
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 RIGHT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE build_target_dimensions.arch = 'ia32'
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_to_sql2_with_filter_overlapping_column
    filter = Filter.new
    filter.name = 'X'
    filter.description = ''
    filter.time_week = 2
    assert_equal(true, filter.valid?, filter.errors.to_xml)

    summarizer = Summarizer.new
    summarizer.name = 'X'
    summarizer.description = ''
    summarizer.primary_dimension = 'build_configuration_name'
    summarizer.secondary_dimension = 'time_day_of_week'
    summarizer.function = 'success_rate'
    assert_equal(true, summarizer.valid?, summarizer.errors.to_xml)

    assert_equal(<<END_SQL, Search.new.perform_search(filter, summarizer).sql)
SELECT
 build_configuration_dimensions.name as row,
 time_dimensions.day_of_week as column,
 CAST(count(case when result_dimensions.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 as value
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 RIGHT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE time_dimensions.week = 2
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_to_sql2_with_filter_overlapping_row
    filter = Filter.new
    filter.name = 'X'
    filter.description = ''
    filter.build_configuration_runtime_compiler = 'opt'
    assert_equal(true, filter.valid?, filter.errors.to_xml)

    summarizer = Summarizer.new
    summarizer.name = 'X'
    summarizer.description = ''
    summarizer.primary_dimension = 'build_configuration_name'
    summarizer.secondary_dimension = 'time_day_of_week'
    summarizer.function = 'success_rate'
    assert_equal(true, summarizer.valid?, summarizer.errors.to_xml)

    assert_equal(<<END_SQL, Search.new.perform_search(filter, summarizer).sql)
SELECT
 build_configuration_dimensions.name as row,
 time_dimensions.day_of_week as column,
 CAST(count(case when result_dimensions.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 as value
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 RIGHT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE build_configuration_dimensions.runtime_compiler = 'opt'
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_to_sql2_with_filter_overlapping_column
    filter = Filter.new
    filter.name = 'X'
    filter.description = ''
    filter.time_week = 2
    assert_equal(true, filter.valid?, filter.errors.to_xml)

    summarizer = Summarizer.new
    summarizer.name = 'X'
    summarizer.description = ''
    summarizer.primary_dimension = 'build_configuration_name'
    summarizer.secondary_dimension = 'time_day_of_week'
    summarizer.function = 'success_rate'
    assert_equal(true, summarizer.valid?, summarizer.errors.to_xml)

    assert_equal(<<END_SQL, Search.new.perform_search(filter, summarizer).sql)
SELECT
 build_configuration_dimensions.name as row,
 time_dimensions.day_of_week as column,
 CAST(count(case when result_dimensions.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 as value
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 RIGHT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE time_dimensions.week = 2
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_to_sql2_with_filter_overlapping_function
    filter = Filter.new
    filter.name = 'X'
    filter.description = ''
    filter.result_name = 'SUCCESS'
    assert_equal(true, filter.valid?, filter.errors.to_xml)

    summarizer = Summarizer.new
    summarizer.name = 'X'
    summarizer.description = ''
    summarizer.primary_dimension = 'build_configuration_name'
    summarizer.secondary_dimension = 'time_day_of_week'
    summarizer.function = 'success_rate'
    assert_equal(true, summarizer.valid?, summarizer.errors.to_xml)

    assert_equal(<<END_SQL, Search.new.perform_search(filter, summarizer).sql)
SELECT
 build_configuration_dimensions.name as row,
 time_dimensions.day_of_week as column,
 CAST(count(case when result_dimensions.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 as value
FROM result_facts
 LEFT JOIN result_dimensions ON result_facts.result_id = result_dimensions.id
 RIGHT JOIN build_configuration_dimensions ON result_facts.build_configuration_id = build_configuration_dimensions.id
 RIGHT JOIN time_dimensions ON result_facts.time_id = time_dimensions.id
WHERE result_dimensions.name = 'SUCCESS'
GROUP BY build_configuration_dimensions.name, time_dimensions.day_of_week
ORDER BY build_configuration_dimensions.name, time_dimensions.day_of_week
END_SQL
  end

  def test_perform_summarizer
    filter = Filter.new
    filter.name = 'X'
    filter.description = ''
    filter.result_name = 'SUCCESS'
    assert_equal(true, filter.valid?, filter.errors.to_xml)

    summarizer = Summarizer.new
    summarizer.name = 'X'
    summarizer.description = ''
    summarizer.primary_dimension = 'build_configuration_name'
    summarizer.secondary_dimension = 'time_day_of_week'
    summarizer.function = 'success_rate'
    assert_equal(true, summarizer.valid?, summarizer.errors.to_xml)

    result = Search.new.perform_search(filter, summarizer)
    assert_not_nil(result)
    assert_not_nil(result.row)
    assert_not_nil(result.column)
    assert_not_nil(result.function)
    assert_not_nil(result.data)
    assert_equal(BuildConfigurationDimension, result.row.dimension)
    assert_equal(:name, result.row.name)
    assert_equal(TimeDimension, result.column.dimension)
    assert_equal(:day_of_week, result.column.name)
    assert_equal([ResultDimension], result.function.dimensions)
  end
end
