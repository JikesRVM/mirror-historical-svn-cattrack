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
class Results::TestCaseController < Results::BaseController
  verify :method => :get, :redirect_to => :access_denied_url
  caches_page :show, :show_output, :show_history
  session :off

  def show
    @record = test_case
  end

  def show_output
    headers['Content-Type'] = 'text/plain'
    render(:text => test_case.output, :layout => false)
  end

  def show_history
    @record = test_case
    sql = <<SQL
select
 tce.*
FROM
(select
 tc.name as test_case_name,
 g.name as group_name,
 c.name as test_configuration_name,
 b.name as build_configuration_name,
 r.name as test_run_name,
 r.start_time as start_time,
 r.variant,
 r.host_id
from
 test_cases tc,
 groups g,
 build_configurations b,
 test_configurations c,
 test_runs r
where
 r.id = b.test_run_id and
 b.id = c.build_configuration_id and
 g.test_configuration_id = c.id and
 tc.group_id = g.id and
 tc.id = #{@record['id']}) this,
 test_case_executions tce,
 test_cases tc,
 groups g,
 build_configurations b,
 test_configurations c,
 test_runs r
where
 r.id = b.test_run_id and
 b.id = c.build_configuration_id and
 g.test_configuration_id = c.id and
 tc.group_id = g.id and
 tce.test_case_id = tc.id and
 this.group_name = g.name and
 this.test_case_name = tc.name and
 this.test_configuration_name = c.name and
 this.build_configuration_name = b.name and
 this.test_run_name = r.name and
 this.host_id = r.host_id and
 this.variant = r.variant and
 this.start_time > r.start_time
order by r.start_time DESC, tce.name
limit 500
SQL
    @history = Tdm::TestCaseExecution.find_by_sql(sql)
  end
end
