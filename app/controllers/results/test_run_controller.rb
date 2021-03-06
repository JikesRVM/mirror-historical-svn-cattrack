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
class Results::TestRunController < Results::BaseController
  verify :method => :get, :except => [:destroy], :redirect_to => :access_denied_url
  verify :method => :delete, :only => [:destroy], :redirect_to => :access_denied_url
  caches_page :show, :show_summary, :regression_report, :performance_report, :statistics_report
  session :off, :except => [:destroy]

  def list_by_variant
    @host = host
    @variant = params[:test_run_variant]
    @test_run_pages, @test_runs =
      paginate(Tdm::TestRun, :per_page => 20, :order => 'start_time DESC', :conditions => ['host_id = ? AND variant = ?', @host.id, @variant])
  end

  def show
    @record = test_run
  end

  def show_summary
    @record = test_run
  end

  def regression_report
    @report = Report::RegressionReport.new(test_run)
  end

  def performance_report
    @report = Report::PerformanceReport.new(test_run)
  end

  def statistics_report
    @report = Report::StatisticsReport.new(test_run)
  end

  def destroy
    raise CatTrack::SecurityError unless is_authenticated?
    @record = test_run
    host_name = @record.host.name
    raise CatTrack::SecurityError unless current_user.admin?
    flash[:notice] = "#{@record.label} was successfully deleted."
    @record.destroy

    base_url = url_for(params.merge(:action => 'show', :only_path => true))
    path = File.expand_path("#{RAILS_ROOT}/public/#{base_url}")
    FileUtils.rm_rf path
    FileUtils.rm_rf "#{path}.html"

    AuditLog.log('test-run.deleted', @record)
    redirect_to(:controller => '/results/host', :action => 'show', :host_name => host_name)
  end
end
