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
class Olap::Query::Filter < ActiveRecord::Base
  validates_length_of :name, :in => 1..75
  validates_length_of :description, :in => 0..256
  validates_uniqueness_of :name

  has_params :params

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

  SearchField = Olap::Query::SearchField

  AutoFields = [
  SearchField.new(Olap::HostDimension, :name),

  SearchField.new(Olap::TestRunDimension, :name),

  SearchField.new(Olap::BuildTargetDimension, :name),
  SearchField.new(Olap::BuildTargetDimension, :arch),
  SearchField.new(Olap::BuildTargetDimension, :address_size),
  SearchField.new(Olap::BuildTargetDimension, :operating_system),

  SearchField.new(Olap::BuildConfigurationDimension, :name),
  SearchField.new(Olap::BuildConfigurationDimension, :bootimage_compiler),
  SearchField.new(Olap::BuildConfigurationDimension, :runtime_compiler),
  SearchField.new(Olap::BuildConfigurationDimension, :mmtk_plan),
  SearchField.new(Olap::BuildConfigurationDimension, :assertion_level),
  SearchField.new(Olap::BuildConfigurationDimension, :bootimage_class_inclusion_policy),

  SearchField.new(Olap::TestConfigurationDimension, :name),
  SearchField.new(Olap::TestConfigurationDimension, :mode),

  SearchField.new(Olap::ResultDimension, :name),
  ].freeze

  Fields = AutoFields | [
  SearchField.new(Olap::TestCaseDimension, :name, :type => :string),
  SearchField.new(Olap::TestCaseDimension, :group, :type => :string),

  SearchField.new(Olap::RevisionDimension, :before, :type => :integer, :synthetic => true),
  SearchField.new(Olap::RevisionDimension, :after, :type => :integer, :synthetic => true),
  SearchField.new(Olap::RevisionDimension, :revision, :type => :integer),

  SearchField.new(Olap::TestRunDimension, :source_id),

  SearchField.new(Olap::TimeDimension, :year),
  SearchField.new(Olap::TimeDimension, :month, :labels => [nil] | Time::RFC2822_MONTH_NAME),
  SearchField.new(Olap::TimeDimension, :week),
  SearchField.new(Olap::TimeDimension, :day_of_week, :labels => [nil] | Time::RFC2822_DAY_NAME),
  SearchField.new(Olap::TimeDimension, :from, :type => :period, :synthetic => true),
  SearchField.new(Olap::TimeDimension, :to, :type => :period, :synthetic => true),
  SearchField.new(Olap::TimeDimension, :before, :type => :date, :synthetic => true),
  SearchField.new(Olap::TimeDimension, :after, :type => :date, :synthetic => true),
  ].freeze

  Fields.each do |field|
    define_method(field.key) do
      params[field.key.to_s]
    end
    define_method("#{field.key}=".to_sym) do |value|
      value = nil if self.class.is_blank?(value)
      params[field.key.to_s] = value
    end
    case field.options[:type]
    when :period then
      validates_each field.key do |record, attr_name, value|
        record.errors.add(attr_name, 'should be properly formatted.') unless nil == value || value =~ PeriodRE
      end
    when :integer then
      validates_each field.key do |record, attr_name, value|
        record.errors.add(attr_name, 'should be properly formatted.') unless nil == value || value =~ /\A[+-]?\d+\Z/
      end
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
    is_blank?(object.send(field_symbol))
  end

  def self.is_blank?(value)
    value.blank? ||
    ( value.instance_of?( Array ) && ( (value.size == 1 and value[0].blank? ) || (value.size == 0)) )
  end

  protected

  def self.filter_criteria(search)
    conditions = []
    cond_params = {}
    joins = []

    AutoFields.each {|f| add_search_term(search, f, conditions, cond_params, joins)}
    add_search_term(search, field(Olap::TestCaseDimension, :name), conditions, cond_params, joins)
    add_search_term(search, field(Olap::TestCaseDimension, :group), conditions, cond_params, joins)
    add_revision_criteria(search, conditions, cond_params, joins)
    add_search_term(search, field(Olap::TimeDimension, :year), conditions, cond_params, joins)
    add_search_term(search, field(Olap::TimeDimension, :month), conditions, cond_params, joins)
    add_search_term(search, field(Olap::TimeDimension, :week), conditions, cond_params, joins)
    add_search_term(search, field(Olap::TimeDimension, :day_of_week), conditions, cond_params, joins)
    add_search_term(search, field(Olap::TestRunDimension, :source_id), conditions, cond_params, joins)

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
      conditions << 'time_dimension.time < :time_before'
      cond_params[:time_before] = search.time_before
      joins << Olap::TimeDimension
    end
    if not is_empty?(search, :time_after)
      conditions << 'time_dimension.time > :time_after'
      cond_params[:time_after] = search.time_after
      joins << Olap::TimeDimension
    end

    if not is_empty?(search, :time_from)
      from_time = period_to_time(Time.now, search.time_from)
      if from_time
        conditions << 'time_dimension.time > :time_from'
        cond_params[:time_from] = from_time.strftime(TimeFormat)
        joins << Olap::TimeDimension
      end
    end

    if not is_empty?(search, :time_to)
      to_time = period_to_time(Time.now, search.time_to)
      if to_time
        conditions << 'time_dimension.time < :time_to'
        cond_params[:time_to] = to_time.strftime(TimeFormat)
        joins << Olap::TimeDimension
      end
    end
  end

  def self.add_revision_criteria(search, conditions, cond_params, joins)
    if not is_empty?(search, :revision_before)
      conditions << 'revision_dimension.revision < :revision_before'
      cond_params[:revision_before] = search.revision_before
      joins << Olap::RevisionDimension
    end

    if not is_empty?(search, :revision_after)
      conditions << 'revision_dimension.revision > :revision_from'
      cond_params[:revision_after] = search.revision_after
      joins << Olap::RevisionDimension
    end
  end
end
