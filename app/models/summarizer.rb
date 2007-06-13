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
class Summarizer < ActiveRecord::Base
  validates_length_of :name, :in => 1..120
  validates_uniqueness_of :name
  validates_length_of :description, :in => 0..256
  validates_length_of :primary_dimension, :in => 1..256
  validates_length_of :secondary_dimension, :in => 1..256
  validates_length_of :function, :in => 1..256

  DimensionFields = Filter::Fields.select {|f| f.options[:synthetic] != true}
  DimensionMap = {}
  DimensionFields.each {|d| DimensionMap[d.key.to_s] = d}
  ValidDimensionFieldIds = DimensionFields.collect {|o| o.key.to_s}

  FunctionField = Struct.new('FunctionField', :id, :label, :sql, :dimensions)
  FunctionFields = [
  FunctionField.new('success_rate', 'Success Rate', "case when :secondary_dimension IS NOT NULL then CAST(count(case when result_dimension.name != 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 else NULL end", [Olap::ResultDimension]),
  FunctionField.new('non_success_rate', 'Non-success Rate', "CAST(count(case when result_dimension.name = 'SUCCESS' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [Olap::ResultDimension]),
  FunctionField.new('failure_rate', 'Failure Rate', "CAST(count(case when result_dimension.name != 'FAILURE' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [Olap::ResultDimension]),
  FunctionField.new('overtime_rate', 'Overtime Rate', "CAST(count(case when result_dimension.name != 'OVERTIME' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [Olap::ResultDimension]),
  FunctionField.new('excluded_rate', 'Excluded Rate', "CAST(count(case when result_dimension.name != 'EXCLUDED' then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0", [Olap::ResultDimension]),
  ]
  FunctionMap = {}
  FunctionFields.each {|f| FunctionMap[f.id] = f}
  ValidFunctionFieldIds = FunctionFields.collect {|o| o.id}

  validates_inclusion_of :function, :in => ValidFunctionFieldIds
  validates_inclusion_of :primary_dimension, :in => ValidDimensionFieldIds
  validates_inclusion_of :secondary_dimension, :in => ValidDimensionFieldIds
  validates_length_of :description, :in => 0..256

  validates_each(:primary_dimension) do |record, attr, value|
    record.errors.add(attr, 'primary and secondary dimensions can not be the same.') if (not record.primary_dimension.nil? and record.primary_dimension == record.secondary_dimension)
  end
end
