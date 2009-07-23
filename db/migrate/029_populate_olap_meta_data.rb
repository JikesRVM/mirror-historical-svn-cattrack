#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
class PopulateOlapMetaData < ActiveRecord::Migration
  class Filter < ActiveRecord::Base
  end

  class Query < ActiveRecord::Base
  end

  class Presentation < ActiveRecord::Base
  end

  class Report < ActiveRecord::Base
  end

  class Measure < ActiveRecord::Base
    has_and_belongs_to_many :presentations, :class_name => 'PopulateOlapMetaData::Presentation'
  end

  def self.rate_measure(name, condition, presentation_ids)
    m = Measure.create!(:name => "#{name} Rate", :sql => "case when :secondary_dimension IS NOT NULL then CAST(count(case when #{condition} then 1 else NULL end) AS double precision) / CAST(count(*) AS double precision) * 100.0 else NULL end", :joins => 'result', :result_measure => true)
    m.presentation_ids = presentation_ids
    m
  end

  def self.up
    ActiveRecord::Base.transaction do
      presentation_1 = Presentation.create!(:name => 'Pivot Table', :key => 'pivot')
      presentation_2 = Presentation.create!(:name => 'Success Rate Table', :key => 'success')
      presentation_3 = Presentation.create!(:name => 'SQL + Raw Data', :key => 'raw')
      presentation_ids = [presentation_1.id, presentation_2.id, presentation_3.id]

      measure_1 = rate_measure('Success', "result_dimension.name = 'SUCCESS'", presentation_ids)
      measure_2 = rate_measure('Non-success', "result_dimension.name != 'SUCCESS'", presentation_ids)
      measure_3 = rate_measure('Failure', "result_dimension.name = 'FAILURE'", presentation_ids)
      measure_4 = rate_measure('Overtime', "result_dimension.name = 'OVERTIME'", presentation_ids)
      measure_5 = rate_measure('Excluded', "result_dimension.name = 'EXCLUDED'", presentation_ids)

      measure_6 = Measure.create!(:name => "Average", :sql => "avg(statistic_facts.value)", :joins => '', :result_measure => false)
      measure_6.presentation_ids = presentation_ids
      measure_7 = Measure.create!(:name => "Maximum", :sql => "max(statistic_facts.value)", :joins => '', :result_measure => false)
      measure_7 = Measure.create!(:name => "Minimum", :sql => "min(statistic_facts.value)", :joins => '', :result_measure => false)
      measure_7 = Measure.create!(:name => "Count", :sql => "count(statistic_facts.value)", :joins => '', :result_measure => false)
      measure_7 = Measure.create!(:name => "Sum", :sql => "sum(statistic_facts.value)", :joins => '', :result_measure => false)
      measure_7 = Measure.create!(:name => "Stddev", :sql => "stddev(statistic_facts.value)", :joins => '', :result_measure => false)
      measure_7 = Measure.create!(:name => "Variance", :sql => "variance(statistic_facts.value)", :joins => '', :result_measure => false)
      measure_7.presentation_ids = presentation_ids

      filter_1 = Filter.create!(:name => 'Empty', :description => 'Does not filter any facts.')

      query_1 = Query.create!(:name => 'Success by Test Configuration by Month', :description => '', :primary_dimension => 'test_configuration_name', :secondary_dimension => 'time_month', :measure_id => measure_1.id, :filter_id => filter_1.id)

      report_1 = Report.create!(:key => 'SxTCxM', :name => 'Success by Test Configuration by Month', :description => '', :presentation_id => presentation_1.id, :query_id => query_1.id)
    end
  end

  def self.down
  end
end
