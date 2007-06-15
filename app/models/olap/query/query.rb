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
class Olap::Query::Query < ActiveRecord::Base
  validates_length_of :name, :in => 1..120
  validates_uniqueness_of :name
  validates_length_of :description, :in => 0..256
  validates_length_of :primary_dimension, :in => 1..256
  validates_length_of :secondary_dimension, :in => 1..256

  validates_presence_of :measure_id, :filter_id
  validates_reference_exists :measure_id, Olap::Query::Measure
  validates_reference_exists :filter_id, Olap::Query::Filter

  belongs_to :measure, :class_name => 'Olap::Query::Measure', :foreign_key => 'measure_id'
  belongs_to :filter, :class_name => 'Olap::Query::Filter', :foreign_key => 'filter_id'

  DimensionFields = Olap::Query::Filter::Fields.select {|f| f.options[:synthetic] != true}
  ValidDimensionFieldIds = DimensionFields.collect {|o| o.key.to_s}

  validates_inclusion_of :primary_dimension, :in => ValidDimensionFieldIds
  validates_inclusion_of :secondary_dimension, :in => ValidDimensionFieldIds

  validates_each(:primary_dimension) do |record, attr, value|
    record.errors.add(attr, 'primary and secondary dimensions can not be the same.') if (not record.primary_dimension.nil? and record.primary_dimension == record.secondary_dimension)
  end

  def perform_search
    conditions, joins = filter.filter_criteria()

    rf = DimensionFields.find {|f| f.key.to_s == primary_dimension}
    cf = DimensionFields.find {|f| f.key.to_s == secondary_dimension}
    rd = rf.dimension
    cd = cf.dimension

    measure.join_dimensions.each{|d| joins << d unless joins.include?(d)}
    joins.delete(rd)
    joins.delete(cd)

    join_sql = joins.uniq.collect {|d| join(d)}.join("\n ") + "\n " + join(rd, 'RIGHT')
    join_sql = join_sql + "\n " + join(cd, 'LEFT') unless (rd == cd)

    criteria = ActiveRecord::Base.send :sanitize_sql_array, conditions
    primary_dimension = "#{rf.dimension.table_name}.#{rf.name}"
    secondary_dimension = "#{cf.dimension.table_name}.#{cf.name}"
    measure_sql = measure.sql.gsub(/\:primary_dimension/,primary_dimension).gsub(/\:secondary_dimension/,secondary_dimension)
    sql = <<END_OF_SQL
SELECT
 #{primary_dimension} AS primary_dimension,
 #{secondary_dimension} AS secondary_dimension,
 #{measure_sql}
FROM result_facts
 #{join_sql}
WHERE #{criteria}
GROUP BY #{primary_dimension}, #{secondary_dimension}
ORDER BY #{primary_dimension}, #{secondary_dimension}
END_OF_SQL

    data = ActiveRecord::Base.connection.select_all(sql)
    Olap::Query::QueryResult.new(sql, rf, cf, measure, data)
  end

  private

  def join(dimension, type = 'LEFT')
    "#{type} JOIN #{dimension.table_name} ON result_facts.#{dimension.table_name[0, dimension.table_name.singularize.size - 10]}_id = #{dimension.table_name}.id"
  end
end
