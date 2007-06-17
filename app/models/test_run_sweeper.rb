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
class TestRunSweeper < ActionController::Caching::Sweeper
  observe Tdm::TestRun

  def after_destroy(data)
    expire_about(data)
  end

  def expire_about(data)
    base_url = url_for(:controller => '/test_run', :action => 'show', :host_id => data.host_id, :id => data.id, :only_path => true)
    path = File.expand_path("#{RAILS_ROOT}/public/#{base_url}")
    FileUtils.rm_rf path
    FileUtils.rm_rf "#{path}.html"
  end
end