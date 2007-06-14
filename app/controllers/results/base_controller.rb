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
class Results::BaseController < ApplicationController
  verify :method => :get, :except => [:destroy], :redirect_to => :access_denied_url

  protected

  def host
    Tdm::Host.find_by_name(params[:host_name])
  end

  def test_run
    host.test_runs.find_by_id_and_name(params[:test_run_id],params[:test_run_name])
  end

  def build_target
    test_run.build_target
  end

  def build_configuration
    test_run.build_configurations.find_by_name(params[:build_configuration_name])
  end

  def test_configuration
    build_configuration.test_configurations.find_by_name(params[:test_configuration_name])
  end

  def group
    test_configuration.groups.find_by_name(params[:group_name])
  end

  def test_case
    group.test_cases.find_by_name(params[:test_case_name])
  end
end
