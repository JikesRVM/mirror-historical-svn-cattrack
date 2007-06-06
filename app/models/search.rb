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
  DimensionFields = Filter::Fields.select {|f| f.options[:synthetic] != true}.collect {|f| f}
  DimensionFieldLabels = {}
  DimensionFields.each {|o| DimensionFieldLabels[o.key.to_s] = "#{o.dimension_name.tableize.humanize}/#{o.name.to_s.humanize}"}
  ValidDimensionFieldIds = DimensionFields.collect {|o| o.key.to_s}

  FunctionField = Struct.new('FunctionField', :id, :label, :sql, :dimensions)
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

  def perform_search(filter)
    if valid?
      data = ActiveRecord::Base.connection.select_all(to_sql(filter))
      ReportResultData.new(row_field, column_field, aggregate_operation, data)
    end
  end

  private

  def to_sql(filter)
    conditions, joins = filter.filter_criteria()

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

  def row_field
    DimensionFields.find {|o| o.key.to_s == row }
  end

  def column_field
    DimensionFields.find {|o| o.key.to_s == column }
  end

  def aggregate_operation
    FunctionFields.find {|o| o.id == function}
  end

  def join(dimension, type = 'LEFT')
    "#{type} JOIN #{dimension.table_name} ON result_facts.#{dimension.table_name[0, dimension.table_name.singularize.size - 10]}_id = #{dimension.table_name}.id"
  end
end
