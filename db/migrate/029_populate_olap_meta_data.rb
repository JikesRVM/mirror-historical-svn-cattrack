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
class PopulateOlapMetaData < ActiveRecord::Migration
  class Presentation < ActiveRecord::Base
  end

  class Measure < ActiveRecord::Base
    has_and_belongs_to_many :presentations, :class_name => 'PopulateOlapMetaData::Presentation'
  end

  def self.rate_measure(name, condition, presentation_ids)
    m = Measure.create!(:name => "#{name} Rate", :sql => "case when :secondary_dimension IS NOT NULL then CAST(count(case when #{condition} then NULL else 1 end) AS double precision) / CAST(count(*) AS double precision) * 100.0 else NULL end", :joins => 'result', :grouping => '')
    m.presentation_ids = presentation_ids
  end

  def self.up
    ActiveRecord::Base.transaction do
      p1 = Presentation.create!(:name => 'Pivot Table', :key => 'pivot')
      p2 = Presentation.create!(:name => 'Success Rate Table', :key => 'success')
      p3 = Presentation.create!(:name => 'SQL + Raw Data', :key => 'raw')
      presentation_ids = [p1.id, p2.id, p3.id]

      rate_measure('Success', "result_dimension.name != 'SUCCESS'", presentation_ids)
      rate_measure('Non-success', "result_dimension.name = 'SUCCESS'", presentation_ids)
      rate_measure('Failure', "result_dimension.name != 'FAILURE'", presentation_ids)
      rate_measure('Overtime', "result_dimension.name != 'OVERTIME'", presentation_ids)
      rate_measure('Excluded', "result_dimension.name != 'EXCLUDED'", presentation_ids)
    end
  end

  def self.down
  end
end
