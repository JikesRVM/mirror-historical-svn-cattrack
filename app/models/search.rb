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

  SearchField.new(RevisionDimension, :before, :type => :integer),
  SearchField.new(RevisionDimension, :after, :type => :integer),

  SearchField.new(TimeDimension, :year),
  SearchField.new(TimeDimension, :month),
  SearchField.new(TimeDimension, :week),
  SearchField.new(TimeDimension, :day_of_week),
  SearchField.new(TimeDimension, :from, :type => :period),
  SearchField.new(TimeDimension, :to, :type => :period),
  SearchField.new(TimeDimension, :before, :type => :date),
  SearchField.new(TimeDimension, :after, :type => :date),
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

  def is_empty?(field_symbol)
    value = self.send(field_symbol)
    value.blank? ||
    ( value.instance_of?( Array ) && ( (value.include?( nil ) && value.size == 1) || (value.size == 0)) )
  end

  def is_defined?(field_symbol, value)
    v = self.send(field_symbol)
    if v.instance_of?( Array )
      return v.include?(value.to_s)
    else
      return v == value.to_s
    end
  end

  def to_sql
    self.class.prepare_sql(self)
  end

  protected

  def self.prepare_sql(search)
    conditions = []
    cond_params = {}
    joins = []

    AutoFields.each do |f|
      add_search_term(search, f, conditions, cond_params, joins)
    end
    add_search_term(search, field(TestCaseDimension,:name), conditions, cond_params, joins)
    add_search_term(search, field(TestCaseDimension,:group), conditions, cond_params, joins)
    add_revision_criteria(search, conditions, cond_params, joins)
    add_search_term(search, field(TimeDimension,:year), conditions, cond_params, joins)
    add_search_term(search, field(TimeDimension,:month), conditions, cond_params, joins)
    add_search_term(search, field(TimeDimension,:week), conditions, cond_params, joins)
    add_search_term(search, field(TimeDimension,:day_of_week), conditions, cond_params, joins)

    add_time_based_search(search, conditions, cond_params, joins)

    join_sql = joins.uniq.collect do |d|
      "LEFT JOIN #{d.table_name} ON result_facts.#{d.table_name[0, d.table_name.singularize.size - 10]}_id = #{d.table_name}.id"
    end.join(' ')

    return '1 = 1' if conditions.empty?

    return [ conditions.join(' AND '), cond_params ], join_sql
  end

  def self.field(dimension,name)
    Fields.find {|f| (f.dimension == dimension) and (f.name == name)}
  end

  def self.add_search_term(search, field, conditions, cond_params, joins)
    if not search.is_empty?(field.key)
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

    if not search.is_empty?(:time_before)
      conditions << 'time_dimensions.time < :time_before'
      cond_params[:time_before] = search.time_before
      joins << TimeDimension
    end
    if not search.is_empty?(:time_after)
      conditions << 'time_dimensions.time > :time_after'
      cond_params[:time_after] = search.time_after
      joins << TimeDimension
    end

    if not search.is_empty?(:time_from)
      from_time = period_to_time(Time.now, search.time_from)
      if from_time
        conditions << 'time_dimensions.time > :time_from'
        cond_params[:time_from] = from_time.strftime(TimeFormat)
        joins << TimeDimension

        if not search.is_empty?(:time_to)
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
    if not search.is_empty?(:revision_before)
      conditions << 'revision_dimensions.revision < :revision_before'
      cond_params[:revision_before] = search.revision_before
      joins << RevisionDimension
    end

    if not search.is_empty?(:revision_after)
      conditions << 'revision_dimensions.revision > :revision_from'
      cond_params[:revision_after] = search.revision_after
      joins << RevisionDimension
    end
  end
end
