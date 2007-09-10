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
class Results::TestCaseStatisticController < Results::BaseController
  verify :method => :get, :redirect_to => :access_denied_url
  caches_page :show
  session :off

  def show
    # NOTE: statistic includes .png extension
    statistic = params[:statistic_key]
    report = Report::PerformanceReport.new(test_run)
    image = Report::PerformanceReportStatisticRenderer.new(report,statistic[0,-4]).to_image
    send_data(image, :type => 'image/png', :filename => statistic, :disposition => 'inline')
  end
end
