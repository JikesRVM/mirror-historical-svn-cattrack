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
class Admin::SysinfoController < Admin::BaseController
  verify :method => :get, :only => [:show], :redirect_to => {:action => :index}
  verify :method => :post, :only => [:purge_stale_sessions, :purge_historic_result_facts], :redirect_to => {:action => :index}

  def show
    @orhpan_dimensions = dimension_data
  end

  def purge_stale_sessions
    SessionCleaner::remove_stale_sessions
    redirect_to(:action => 'show')
  end

  def purge_historic_result_facts
    ResultFact.destroy_all(['source_id IS NULL'])
    redirect_to(:action => 'show')
  end

  def purge_historic_statistic_facts
    StatisticFact.destroy_all(['source_id IS NULL'])
    redirect_to(:action => 'show')
  end

  def purge_orphan_dimensions
    Dimensions.collect do |d|
      name = d.name[0, d.name.length - 9]
      column_name = name.tableize.singularize + "_id"
      sql = []
      sql << ((d != StatisticDimension) ? "id NOT IN (SELECT DISTINCT #{column_name} FROM result_facts)" : '1 = 1')
      sql << ((d != ResultDimension) ? "id NOT IN (SELECT DISTINCT #{column_name} FROM statistic_facts)" : '1 = 1')
      d.destroy_all(sql.join(' AND '))
    end
    redirect_to(:action => 'show')
  end

  private

  Dimensions = [HostDimension, TestRunDimension, TestConfigurationDimension, BuildConfigurationDimension, BuildTargetDimension, TestCaseDimension, TimeDimension, RevisionDimension, ResultDimension, StatisticDimension]

  def dimension_data
    Dimensions.collect do |d|
      name = d.name[0, d.name.length - 9]
      column_name = name.tableize.singularize + "_id"
      result_fact_count = (d != StatisticDimension) ? d.count(:conditions => "id NOT IN (SELECT DISTINCT #{column_name} FROM result_facts)") : 0
      statistic_fact_count = (d != ResultDimension) ? d.count(:conditions => "id NOT IN (SELECT DISTINCT #{column_name} FROM statistic_facts)") : 0
      [name, result_fact_count + statistic_fact_count, d]
    end
  end
end
