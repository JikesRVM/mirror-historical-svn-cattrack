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
class Filter < ActiveRecord::Base
  has_params :params
  auto_validations :except => [:id, :description]
  validates_length_of :description, :in => 0..256

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
    define_method(field.key) do
      params[field.key.to_s]
    end
    define_method("#{field.key}=".to_sym) do |value|
      params[field.key.to_s] = value
    end
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

  def filter_criteria
    self.class.filter_criteria(self)
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
      end
    end

    if not is_empty?(search, :time_to)
      to_time = period_to_time(Time.now, search.time_to)
      if to_time
        conditions << 'time_dimensions.time < :time_to'
        cond_params[:time_to] = to_time.strftime(TimeFormat)
        joins << TimeDimension
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
