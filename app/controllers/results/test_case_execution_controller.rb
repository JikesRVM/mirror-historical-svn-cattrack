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
class Results::TestCaseExecutionController < Results::BaseController
  verify :method => :get, :redirect_to => :access_denied_url
  caches_page :show
  session :off

  def list_by_matching_output
    return unless params[:q]
    @test_case_executions = Tdm::TestCaseExecution.find_by_sql(<<SQL)
SELECT test_case_executions.*
FROM test_runs, hosts, build_configurations, test_configurations, groups, test_cases, test_case_executions
WHERE
  hosts.id = test_runs.host_id AND
  build_configurations.test_run_id = test_runs.id AND
  test_configurations.build_configuration_id = build_configurations.id AND
  groups.test_configuration_id = test_configurations.id AND
  test_cases.group_id = groups.id AND
  test_case_executions.test_case_id = test_cases.id AND
  test_case_executions.id IN (SELECT owner_id FROM test_case_execution_outputs WHERE output LIKE #{ActiveRecord::Base.connection.quote("%#{params[:q]}%")})
ORDER BY test_runs.start_time DESC
SQL
  end

  def show
    headers['Content-Type'] = 'text/plain'
    render(:text => test_case_execution.output, :layout => false)
  end
end
