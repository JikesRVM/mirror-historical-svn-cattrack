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
  verify :method => :get, :only => [:show], :redirect_to => :access_denied_url
  verify :method => :post, :only => [:purge_stale_sessions, :purge_historic_result_facts], :redirect_to => :access_denied_url

  def show
    @orhpan_dimensions = dimension_data
  end

  def purge_stale_sessions
    SessionCleaner::remove_stale_sessions
    redirect_to(:action => 'show')
  end

  def purge_historic_result_facts
    Olap::ResultFact.destroy_all(['source_id IS NULL'])
    redirect_to(:action => 'show')
  end

  def purge_historic_statistic_facts
    Olap::StatisticFact.destroy_all(['source_id IS NULL'])
    redirect_to(:action => 'show')
  end

  def purge_orphan_dimensions
    Dimensions.collect do |d|
      sql = []
      sql << ((d != Olap::StatisticDimension) ? "id NOT IN (SELECT DISTINCT #{d.relation_name} FROM result_facts)" : '1 = 1')
      sql << ((d != Olap::ResultDimension) ? "id NOT IN (SELECT DISTINCT #{d.relation_name} FROM statistic_facts)" : '1 = 1')
      d.destroy_all(sql.join(' AND '))
    end
    redirect_to(:action => 'show')
  end

  private

  Dimensions = [Olap::HostDimension, Olap::TestRunDimension, Olap::TestConfigurationDimension, Olap::BuildConfigurationDimension, Olap::BuildTargetDimension, Olap::TestCaseDimension, Olap::TimeDimension, Olap::RevisionDimension, Olap::ResultDimension, Olap::StatisticDimension]

  def dimension_data
    Dimensions.collect do |d|
      result_fact_count = (d != Olap::StatisticDimension) ? d.count(:conditions => "id NOT IN (SELECT DISTINCT #{d.relation_name} FROM result_facts)") : 0
      statistic_fact_count = (d != Olap::ResultDimension) ? d.count(:conditions => "id NOT IN (SELECT DISTINCT #{d.relation_name} FROM statistic_facts)") : 0
      [d.short_name.classify, result_fact_count + statistic_fact_count, d]
    end
  end
end
