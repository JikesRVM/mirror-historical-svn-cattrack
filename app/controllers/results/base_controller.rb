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
    ep(Tdm::Host.find_by_name(params[:host_name]))
  end

  def test_run
    h = host
    test_run = h.test_runs.find_by_id_and_variant(params[:test_run_id],params[:test_run_variant])
    ep(test_run)
    # reducing the number of database hits.
    test_run.host = h
    test_run
  end

  def build_target
    ep(test_run.build_target)
  end

  def build_configuration
    ep(test_run.build_configurations.find_by_name(params[:build_configuration_name]))
  end

  def test_configuration
    ep(build_configuration.test_configurations.find_by_name(params[:test_configuration_name]))
  end

  def group
    ep(test_configuration.groups.find_by_name(params[:group_name]))
  end

  def test_case
    ep(group.test_cases.find_by_name(params[:test_case_name]))
  end

  def test_case_compilation
    ep(test_case.test_case_compilation)
  end

  def test_case_execution
    ep(test_case.test_case_executions.find_by_name(params[:test_case_execution_name]))
  end

  # if specified object is nil then raise exception, else return object
  def ep(object)
    raise CatTrack::SecurityError unless object
    object
  end
end
