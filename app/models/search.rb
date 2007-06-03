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
class Search < ActiveForm

  TimeFormat = '%Y-%m-%d %H:%M:%S'

  DateRE = /(^ *$)|(^ *[0-9]{4,4}-[0-9]{2,2}-[0-9]{2,2} *$)/
  PeriodRE = /^ *[\+|\-]?[0-9]+[m|w|d|h]( *[\+|\-]?[0-9]+[m|w|d|h])* *$/
  PeriodHourRE = /([\+|\-]?)([0-9]+)([m|w|d|h])/
  PeriodHourModifiers = {
  'm' => (30 * 24),
  'w' => (7 * 24),
  'd' => 24,
  'h' => 1
  }.freeze

  AutoFields = [
  SearchField.new(HostDimension, :name),

  SearchField.new(TestRunDimension, :name),

  SearchField.new(BuildTargetDimension, :name),
  SearchField.new(BuildTargetDimension, :arch, :size => 3),
  SearchField.new(BuildTargetDimension, :address_size, :size => 3),
  SearchField.new(BuildTargetDimension, :operating_system),

  SearchField.new(BuildConfigurationDimension, :name),
  SearchField.new(BuildConfigurationDimension, :bootimage_compiler, :size => 3),
  SearchField.new(BuildConfigurationDimension, :runtime_compiler, :size => 3),
  SearchField.new(BuildConfigurationDimension, :mmtk_plan),
  SearchField.new(BuildConfigurationDimension, :assertion_level),
  SearchField.new(BuildConfigurationDimension, :bootimage_class_inclusion_policy, :size => 3),

  SearchField.new(TestConfigurationDimension, :name),
  SearchField.new(TestConfigurationDimension, :mode, :size => 3),

  SearchField.new(ResultDimension, :name),
  ].freeze

  Fields = AutoFields | [
  SearchField.new(TestCaseDimension, :name, :type => :string),
  SearchField.new(TestCaseDimension, :group, :type => :string),

  SearchField.new(RevisionDimension, :before, :type => :integer, :synthetic => true),
  SearchField.new(RevisionDimension, :after, :type => :integer, :synthetic => true),
  SearchField.new(RevisionDimension, :revision, :type => :integer),

  SearchField.new(TimeDimension, :year),
  SearchField.new(TimeDimension, :month, :labels => [nil] | Time::RFC2822_MONTH_NAME),
  SearchField.new(TimeDimension, :week),
  SearchField.new(TimeDimension, :day_of_week, :labels => [nil] | Time::RFC2822_DAY_NAME),
  SearchField.new(TimeDimension, :from, :type => :period, :synthetic => true),
  SearchField.new(TimeDimension, :to, :type => :period, :synthetic => true),
  SearchField.new(TimeDimension, :before, :type => :date, :synthetic => true),
  SearchField.new(TimeDimension, :after, :type => :date, :synthetic => true),
  ].freeze

  Fields.each do |field|
    attr_accessor field.key
    case field.options[:type]
    when :period then
      validates_each field.key do |record, attr_name, value|
        record.errors.add(attr_name, 'should be properly formatted.') unless nil == value || value =~ PeriodRE
      end
    when :integer then
      validates_numericality_of field.key, :allow_nil => true, :only_integer => true
    when :date then
      validates_each field.key do |record, attr_name, value|
        record.errors.add(attr_name, 'should be properly formatted.') unless nil == value || value =~ DateRE
      end
    end
  end

  DimensionFields = Search::Fields.select {|f| f.options[:synthetic] != true}.collect {|f| f}
  DimensionFieldLabels = {}
  DimensionFields.each {|o| DimensionFieldLabels[o.key.to_s] = "#{o.dimension_name.tableize.humanize}/#{o.name.to_s.humanize}"}
  ValidDimensionFieldIds = DimensionFields.collect {|o| o.key.to_s}

  FunctionFields = [
  FunctionField.new('success_rate', 'Success Rate', "CAST(count(case when result_dimensions.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [ResultDimension]),
  FunctionField.new('non_success_rate', 'Non-success Rate', "CAST(count(case when result_dimensions.name = 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [ResultDimension]),
  FunctionField.new('failure_rate', 'Failure Rate', "CAST(count(case when result_dimensions.name != 'FAILURE' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [ResultDimension]),
  FunctionField.new('overtime_rate', 'Overtime Rate', "CAST(count(case when result_dimensions.name != 'OVERTIME' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [ResultDimension]),
  FunctionField.new('excluded_rate', 'Excluded Rate', "CAST(count(case when result_dimensions.name != 'EXCLUDED' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [ResultDimension]),
  ]

  validates_inclusion_of :function, :in => FunctionFields.collect {|o| o.id}
  validates_inclusion_of :row, :in => ValidDimensionFieldIds
  validates_inclusion_of :column, :in => ValidDimensionFieldIds
  validates_presence_of :row, :column, :function

  validates_each(:row, :column) do |record, attr, value|
    record.errors.add(attr, 'row and column can not be the same.') if (not record.row.nil? and record.row == record.column)
  end

  attr_accessor :function, :row, :column

  def row_field
    DimensionFields.find {|o| o.key.to_s == row }
  end

  def column_field
    DimensionFields.find {|o| o.key.to_s == column }
  end

  def aggregate_operation
    FunctionFields.find {|o| o.id == function}
  end

  def to_sql
    conditions, joins = self.class.filter_criteria(self)

    rf = row_field
    cf = column_field
    f = aggregate_operation
    rd = rf.dimension
    cd = cf.dimension

    f.dimensions.each{|d| joins << d unless joins.include?(d)}
    joins.delete(rd)
    joins.delete(cd)

    join_sql = joins.uniq.collect {|d| join(d)}.join("\n ") + "\n " + join(rd, 'RIGHT')
    join_sql = join_sql + "\n " + join(cd, 'RIGHT') unless (rd == cd)

    criteria = ActiveRecord::Base.send :sanitize_sql_array, conditions
    row = "#{rd.table_name}.#{rf.name}"
    column = "#{cd.table_name}.#{cf.name}"
    return <<END_OF_SQL
SELECT
 #{row} as row,
 #{column} as column,
 #{f.sql} as value
FROM result_facts
 #{join_sql}
WHERE #{criteria}
GROUP BY #{row}, #{column}
ORDER BY #{row}, #{column}
END_OF_SQL
  end

  def perform_search
    if valid?
      data = ActiveRecord::Base.connection.select_all(to_sql)
      ReportResultData.new(row_field, column_field, aggregate_operation, data)
    end
  end

  def self.is_empty?(object, field_symbol)
    value = object.send(field_symbol)
    value.blank? ||
    ( value.instance_of?( Array ) && ( (value.include?( nil ) && value.size == 1) || (value.size == 0)) )
  end

  protected

  def self.filter_criteria(search)
    conditions = []
    cond_params = {}
    joins = []

    AutoFields.each {|f| add_search_term(search, f, conditions, cond_params, joins)}
    add_search_term(search, field(TestCaseDimension, :name), conditions, cond_params, joins)
    add_search_term(search, field(TestCaseDimension, :group), conditions, cond_params, joins)
    add_revision_criteria(search, conditions, cond_params, joins)
    add_search_term(search, field(TimeDimension, :year), conditions, cond_params, joins)
    add_search_term(search, field(TimeDimension, :month), conditions, cond_params, joins)
    add_search_term(search, field(TimeDimension, :week), conditions, cond_params, joins)
    add_search_term(search, field(TimeDimension, :day_of_week), conditions, cond_params, joins)

    add_time_based_search(search, conditions, cond_params, joins)

    return '1 = 1', [] if conditions.empty?

    return [ conditions.join(' AND '), cond_params ], joins.uniq
  end

  def join(dimension, type = 'LEFT')
    "#{type} JOIN #{dimension.table_name} ON result_facts.#{dimension.table_name[0, dimension.table_name.singularize.size - 10]}_id = #{dimension.table_name}.id"
  end

  def self.field(dimension, name)
    Fields.find {|f| (f.dimension == dimension) and (f.name == name)}
  end

  def self.add_search_term(search, field, conditions, cond_params, joins)
    if not is_empty?(search, field.key)
      value = search.send(field.key)
      value = value[0] if (value.instance_of?( Array ) and value.size == 1)
      key_name = "#{field.dimension.table_name}.#{field.name}"
      if value.instance_of?( Array )
        conditions << "#{key_name} IN (:#{field.key})"
      else
        conditions << "#{key_name} = :#{field.key}"
      end
      joins << field.dimension
      cond_params[field.key] = value
    end
  end

  def self.calculate_hour_offset(text)
    return nil unless (text =~ PeriodRE)

    total = 0
    text.split(/\s+/).each do |element|
      m = PeriodHourRE.match(element)
      sign, count, time_type = m[1], m[2].to_i, m[3]
      count *= PeriodHourModifiers[time_type]
      if sign == '-'
        total -= count
      else
        total += count
      end
    end
    total
  end

  def self.period_to_time(time, text)
    hour_offset = calculate_hour_offset(text)
    ( nil == hour_offset ) ? nil : time + (60 * 60 * hour_offset)
  end

  def self.add_time_based_search(search, conditions, cond_params, joins)
    add_join = false

    if not is_empty?(search, :time_before)
      conditions << 'time_dimensions.time < :time_before'
      cond_params[:time_before] = search.time_before
      joins << TimeDimension
    end
    if not is_empty?(search, :time_after)
      conditions << 'time_dimensions.time > :time_after'
      cond_params[:time_after] = search.time_after
      joins << TimeDimension
    end

    if not is_empty?(search, :time_from)
      from_time = period_to_time(Time.now, search.time_from)
      if from_time
        conditions << 'time_dimensions.time > :time_from'
        cond_params[:time_from] = from_time.strftime(TimeFormat)
        joins << TimeDimension

        if not is_empty?(search, :time_to)
          to_time = period_to_time(from_time, search.time_to)
          if to_time
            conditions << 'time_dimensions.time < :time_to'
            cond_params[:time_to] = to_time.strftime(TimeFormat)
          end
        end
      end
    end
  end

  def self.add_revision_criteria(search, conditions, cond_params, joins)
    if not is_empty?(search, :revision_before)
      conditions << 'revision_dimensions.revision < :revision_before'
      cond_params[:revision_before] = search.revision_before
      joins << RevisionDimension
    end

    if not is_empty?(search, :revision_after)
      conditions << 'revision_dimensions.revision > :revision_from'
      cond_params[:revision_after] = search.revision_after
      joins << RevisionDimension
    end
  end
end
