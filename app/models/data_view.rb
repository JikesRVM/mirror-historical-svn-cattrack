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
class DataView < ActiveRecord::Base
  validates_presence_of :filter_id, :summarizer_id, :data_presentation_id   

  validates_reference_exists :filter_id, Filter
  validates_reference_exists :summarizer_id, Summarizer
  validates_reference_exists :data_presentation_id, DataPresentation

  belongs_to :filter
  belongs_to :summarizer
  belongs_to :data_presentation

  def perform_search
    conditions, joins = filter.filter_criteria()

    rf = Summarizer::DimensionMap[summarizer.primary_dimension]
    cf = Summarizer::DimensionMap[summarizer.secondary_dimension]
    f = Summarizer::FunctionMap[summarizer.function]
    rd = rf.dimension
    cd = cf.dimension

    f.dimensions.each{|d| joins << d unless joins.include?(d)}
    joins.delete(rd)
    joins.delete(cd)

    join_sql = joins.uniq.collect {|d| join(d)}.join("\n ") + "\n " + join(rd, 'RIGHT')
    join_sql = join_sql + "\n " + join(cd, 'LEFT') unless (rd == cd)

    criteria = ActiveRecord::Base.send :sanitize_sql_array, conditions
    primary_dimension = "#{rf.dimension.table_name}.#{rf.name}"
    secondary_dimension = "#{cf.dimension.table_name}.#{cf.name}"
    function_sql = f.sql.gsub(/\:primary_dimension/,primary_dimension).gsub(/\:secondary_dimension/,secondary_dimension)
    sql = <<END_OF_SQL
SELECT
 #{primary_dimension} AS primary_dimension,
 #{secondary_dimension} AS secondary_dimension,
 #{function_sql}
FROM result_facts
 #{join_sql}
WHERE #{criteria}
GROUP BY #{primary_dimension}, #{secondary_dimension}
ORDER BY #{primary_dimension}, #{secondary_dimension}
END_OF_SQL

    data = ActiveRecord::Base.connection.select_all(sql)
    ReportResultData.new(sql, rf, cf, f, data)
  end

  def join(dimension, type = 'LEFT')
    "#{type} JOIN #{dimension.table_name} ON result_facts.#{dimension.table_name[0, dimension.table_name.singularize.size - 10]}_id = #{dimension.table_name}.id"
  end
end
