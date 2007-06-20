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
class Results::TestRunController < Results::BaseController
  verify :method => :get, :except => [:destroy], :redirect_to => :access_denied_url
  verify :method => :delete, :only => [:destroy], :redirect_to => :access_denied_url
  caches_page :show, :show_summary
  session :off, :except => [:destroy]

  def show
    @record = test_run
  end

  def show_summary
    @record = test_run
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
