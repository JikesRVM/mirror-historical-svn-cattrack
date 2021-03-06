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
class Results::TestCaseStatisticController < Results::BaseController
  verify :method => :get, :redirect_to => :access_denied_url
  caches_page :show
  session :off

  def show
    # NOTE: statistic includes .png extension
    statistic = params[:statistic_key]
    statistic = statistic[0,statistic.length-4] if (statistic =~ /.png$/)
    large = (statistic =~ /.large$/)
    statistic = statistic[0, statistic.length-6] if large
    image = Report::PerformanceReportStatisticRenderer.new(test_run, statistic, large).to_image
    headers['Content-Type'] = 'image/png'
    send_data(image, :type => 'image/png', :filename => statistic, :disposition => 'inline')
  end
end
