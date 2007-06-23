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

class Olap::Query::FilterTest < Test::Unit::TestCase
  def test_label
    assert_equal( Olap::Query::Filter.find(1).name, Olap::Query::Filter.find(1).label )
  end

  def test_basic_load
    filter = Olap::Query::Filter.find(1)
    assert_equal( 1, filter.id )
    assert_equal( "Last Week", filter.name )
    assert_equal( 'Filter out results not in last week', filter.description )

    assert_params_same({'time_from' => '-1w'}, filter.params)

    filter = Olap::Query::Filter.find(2)
    assert_equal( 2, filter.id )
    assert_equal( "Core Configurations", filter.name )
    assert_equal( '', filter.description )
    assert_equal(1, filter.params.size)

    assert_equal(["development", "production", "prototype", "prototype-opt"], filter.params['build_configuration_name'].sort)
  end

  def self.attributes_for_new
    {:name => 'foo', :description => ''}
  end
  def self.non_null_attributes
    [:name, :description]
  end
  def self.unique_attributes
    [[:name]]
  end
  def self.str_length_attributes
    [[:name, 75],[:description,256]]
  end

  perform_basic_model_tests

  def test_new_filter_with_blank_attributes
    filter = Olap::Query::Filter.new
    filter.time_from = 'X'
    assert_not_nil( filter.time_from )
    filter.time_from = ''
    assert_nil( filter.time_from )
    filter.time_from = 'X'
    assert_not_nil( filter.time_from )
    filter.time_to = ['']
    assert_nil( filter.time_to )
  end

  def test_is_empty
    assert_equal(true, Olap::Query::Filter.is_empty?(Olap::Query::Filter.new(:host_name => nil), :host_name))
    assert_equal(true, Olap::Query::Filter.is_empty?(Olap::Query::Filter.new(:host_name => ''), :host_name))
    assert_equal(true, Olap::Query::Filter.is_empty?(Olap::Query::Filter.new(:host_name => []), :host_name))
    assert_equal(true, Olap::Query::Filter.is_empty?(Olap::Query::Filter.new(:host_name => [nil]), :host_name))
    assert_equal(false, Olap::Query::Filter.is_empty?(Olap::Query::Filter.new(:host_name => ['a', nil]), :host_name))
    assert_equal(false, Olap::Query::Filter.is_empty?(Olap::Query::Filter.new(:host_name => 'a'), :host_name))
  end

  def test_empty_search_filter_criteria
    conditions, join_sql = Olap::Query::Filter.new.filter_criteria
    assert_equal('1 = 1', conditions)
    assert_equal([], join_sql)
  end

  def test_search_filter_criteria_for_single_value_parameter
    conditions, join_sql = Olap::Query::Filter.new(:host_name => 'ace').filter_criteria
    assert_equal(["host_dimension.name = :host_name", {:host_name=>"ace"}], conditions)
    assert_equal([Olap::HostDimension], join_sql)
  end

  def test_search_filter_criteria_for_single_value_parameter_on_statistic_query
    conditions, join_sql = Olap::Query::Filter.new(:statistic_name => 'ace', :query_type => 'statistic').filter_criteria
    assert_equal(["statistic_dimension.name = :statistic_name", {:statistic_name=>"ace"}], conditions)
    assert_equal([Olap::StatisticDimension], join_sql)
  end

  def test_search_filter_criteria_for_single_value_parameter_with_statistic_param_on_non_statistic_query
    conditions, join_sql = Olap::Query::Filter.new(:host_name => 'ace', :statistic_name => "ace").filter_criteria
    assert_equal(["host_dimension.name = :host_name", {:host_name=>"ace"}], conditions)
    assert_equal([Olap::HostDimension], join_sql)
  end

  def test_search_filter_criteria_for_single_value_parameter_in_array
    conditions, join_sql = Olap::Query::Filter.new(:host_name => ['ace']).filter_criteria
    assert_equal(["host_dimension.name = :host_name", {:host_name=>"ace"}], conditions)
    assert_equal([Olap::HostDimension], join_sql)
  end

  def test_search_filter_criteria_for_test_run_source_id
    conditions, join_sql = Olap::Query::Filter.new(:test_run_source_id => 1).filter_criteria
    assert_equal(["test_run_dimension.source_id = :test_run_source_id", {:test_run_source_id=>1}], conditions)
    assert_equal([Olap::TestRunDimension], join_sql)
  end

  def test_search_filter_criteria_for_multi_value_parameter
    conditions, join_sql = Olap::Query::Filter.new(:host_name => ['ace', 'baby']).filter_criteria
    assert_equal(["host_dimension.name IN (:host_name)", {:host_name=>['ace', 'baby']}], conditions)
    assert_equal([Olap::HostDimension], join_sql)
  end

  def test_search_filter_criteria_for_multiple_parameters
    conditions, join_sql = Olap::Query::Filter.new(:host_name => 'ace', :test_run_name => 'foo').filter_criteria
    assert_equal(["host_dimension.name = :host_name AND test_run_dimension.name = :test_run_name", {:test_run_name=>"foo", :host_name=>"ace"}], conditions)
    assert_equal([Olap::HostDimension, Olap::TestRunDimension], join_sql)
  end

  def test_search_filter_criteria_for_multiple_parameters_on_same_table
    conditions, join_sql = Olap::Query::Filter.new(:test_case_name => 'ace', :test_case_group => 'foo').filter_criteria
    assert_equal(["test_case_dimension.name = :test_case_name AND test_case_dimension.group = :test_case_group", {:test_case_name=>"ace", :test_case_group=>"foo"}], conditions)
    assert_equal([Olap::TestCaseDimension], join_sql)
  end

  def test_calculate_hour_offset
    assert_hour_offset(nil, '')
    assert_hour_offset(1, '1h')
    assert_hour_offset(17, '17h')
    assert_hour_offset(-3, '-3h')
    assert_hour_offset(72, '3d')
    assert_hour_offset(336, '2w')
    assert_hour_offset(2880, '4m')
    assert_hour_offset(37, '1d 13h')
    assert_hour_offset(36, '1d +12h')
    assert_hour_offset(42, '1d 12h 6h -3w +3w')
  end

  def test_period_to_time
    time = Time.utc(1979, 11, 07, 0)
    assert_period_to_time(nil, time, '')
    assert_period_to_time('1979-11-07 01:00:00', time, '1h')
    assert_period_to_time('1979-11-07 17:00:00', time, '17h')
    assert_period_to_time('1979-11-06 21:00:00', time, '-3h')
    assert_period_to_time('1979-11-10 00:00:00', time, '3d')
    assert_period_to_time('1979-11-21 00:00:00', time, '2w')
    assert_period_to_time('1980-03-06 00:00:00', time, '4m')
    assert_period_to_time('1979-11-08 13:00:00', time, '1d 13h')
    assert_period_to_time('1979-11-08 12:00:00', time, '1d +12h')
    assert_period_to_time('1979-11-08 18:00:00', time, '1d 12h 6h -3w +3w')
  end

  def assert_hour_offset(count, description)
    assert_equal(count, Olap::Query::Filter.calculate_hour_offset(description))
  end

  def assert_period_to_time(expected, time, description)
    pt = Olap::Query::Filter.period_to_time(time, description)
    assert_equal(expected, pt ? pt.strftime(Olap::Query::Filter::TimeFormat) : nil)
  end

  def test_before_revision
    conditions, join_sql = Olap::Query::Filter.new(:revision_before => '1234').filter_criteria
    assert_equal(["revision_dimension.revision < :revision_before", {:revision_before=>"1234"}], conditions)
    assert_equal([Olap::RevisionDimension], join_sql)
  end

  def test_after_revision
    conditions, join_sql = Olap::Query::Filter.new(:revision_after => '1234').filter_criteria
    assert_equal(["revision_dimension.revision > :revision_from", {:revision_after=>"1234"}], conditions)
    assert_equal([Olap::RevisionDimension], join_sql)
  end

  def test_add_time_based_search
    search = Olap::Query::Filter.new
    search.time_before = '1979-11-07 00:00:00'
    search.time_after = '1977-10-20 00:00:00'
    conditions = []
    cond_params = {}
    joins = []
    Olap::Query::Filter.add_time_based_search(search, conditions, cond_params, joins)
    assert_equal(2, conditions.length)
    assert_equal(['time_dimension.time < :time_before', 'time_dimension.time > :time_after'], conditions)
    assert_equal([Olap::TimeDimension], joins.uniq)
    assert_equal(2, cond_params.length)
    assert_equal('1979-11-07 00:00:00', cond_params[:time_before])
    assert_equal('1977-10-20 00:00:00', cond_params[:time_after])
  end

  def test_add_time_based_search_with_period
    search = Olap::Query::Filter.new
    search.time_from = '-1d'
    search.time_to = '-0d'
    conditions = []
    cond_params = {}
    joins = []
    Olap::Query::Filter.add_time_based_search(search, conditions, cond_params, joins)
    assert_equal(['time_dimension.time > :time_from', 'time_dimension.time < :time_to'], conditions)
    assert_equal([Olap::TimeDimension, Olap::TimeDimension], joins)
    assert_equal(2, cond_params.length)
    # just assert that entrys exist - too hard to verify
    # stuff already tested elsewhere
    assert(cond_params[:time_from])
    assert(cond_params[:time_to])
  end

  def test_gen_sql
    filter = Olap::Query::Filter.new
    filter.name = 'X'
    filter.time_before = '1979-11-07 00:00:00'
    filter.time_year = 2007
    filter.time_month = 'Oct'
    filter.time_week = 53
    filter.time_day_of_week = ['Mon', 'Tue']

    filter.test_run_name = 'foo'

    filter.build_target_name = ['foo', 'bar', 'baz']
    filter.build_target_arch = 'ia32'
    filter.build_target_address_size = 32
    filter.build_target_operating_system = ['Linux', 'OSX', 'AIX']

    filter.build_configuration_name = 'prototype'
    filter.build_configuration_bootimage_compiler = 'opt'
    filter.build_configuration_runtime_compiler = 'base'
    filter.build_configuration_mmtk_plan = 'com.biz.Foo'
    filter.build_configuration_assertion_level = 'normal'
    filter.build_configuration_bootimage_class_inclusion_policy = 'sane'

    filter.test_configuration_name = 'prototype'
    filter.test_configuration_mode = ''

    filter.result_name = 'SUCCESS'

    conditions, join_sql = filter.filter_criteria
    assert_equal("test_run_dimension.name = :test_run_name AND build_target_dimension.name IN (:build_target_name) AND build_target_dimension.arch = :build_target_arch AND build_target_dimension.address_size = :build_target_address_size AND build_target_dimension.operating_system IN (:build_target_operating_system) AND build_configuration_dimension.name = :build_configuration_name AND build_configuration_dimension.bootimage_compiler = :build_configuration_bootimage_compiler AND build_configuration_dimension.runtime_compiler = :build_configuration_runtime_compiler AND build_configuration_dimension.mmtk_plan = :build_configuration_mmtk_plan AND build_configuration_dimension.assertion_level = :build_configuration_assertion_level AND build_configuration_dimension.bootimage_class_inclusion_policy = :build_configuration_bootimage_class_inclusion_policy AND test_configuration_dimension.name = :test_configuration_name AND result_dimension.name = :result_name AND time_dimension.year = :time_year AND time_dimension.month = :time_month AND time_dimension.week = :time_week AND time_dimension.day_of_week IN (:time_day_of_week) AND time_dimension.time < :time_before", conditions[0])
    assert_equal( {:build_configuration_runtime_compiler=>"base",
    :time_before => "1979-11-07 00:00:00",
    :time_year => 2007,
    :time_month => 'Oct',
    :time_week => 53,
    :time_day_of_week => ["Mon", "Tue"],
    :test_configuration_name => "prototype",
    :test_run_name => "foo",
    :build_target_address_size => 32,
    :build_target_operating_system => ["Linux", "OSX", "AIX"],
    :build_configuration_bootimage_compiler => "opt",
    :build_configuration_bootimage_class_inclusion_policy => "sane",
    :build_configuration_mmtk_plan => "com.biz.Foo",
    :result_name => "SUCCESS",
    :build_configuration_assertion_level => "normal",
    :build_target_arch => "ia32",
    :build_target_name => ["foo", "bar", "baz"],
    :build_configuration_name => "prototype"}, conditions[1])
    assert_equal([Olap::TestRunDimension, Olap::BuildTargetDimension, Olap::BuildConfigurationDimension, Olap::TestConfigurationDimension, Olap::ResultDimension, Olap::TimeDimension], join_sql)
  end
end
