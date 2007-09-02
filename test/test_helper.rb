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
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = true
  self.display_invalid_content = true
  self.auto_validate = true

  fixtures ::OrderedTables

  def assert_params_same(expected, actual)
    assert_equal( expected.size, actual.size )
    expected.each do |k, v|
      assert_equal( actual[k], v, "Testing Key #{k}" )
    end
  end

  def purge_log
    AuditLog.destroy_all
  end

  def assert_logs(messages, user_id = nil, ip_address = '0.0.0.0')
    logs = AuditLog.find(:all, :order => 'created_at')
    assert_equal(messages, logs.collect {|l| [l.name, l.message]})
    logs.each do |l|
      assert_equal(user_id, l.user_id)
      assert_equal(ip_address, l.ip_address)
    end
  end

  def assert_parent_node(object, type = nil, id = nil)
    node = object.parent_node
    if type.nil?
      assert_nil(node)
    else
      assert_kind_of(type, node)
      assert_equal(id, node.id)
    end
  end

  def clone_test_run(_test_run, offset)
    test_run = Tdm::TestRun.new(_test_run.attributes)
    test_run.revision -= offset
    test_run.start_time = test_run.start_time - offset
    test_run.save!

    bt = Tdm::BuildTarget.new(_test_run.build_target.attributes)
    bt.test_run_id = test_run.id
    _test_run.build_target.params.each_pair do |k, v|
      bt.params[k] = v
    end
    bt.save!

    _test_run.build_configurations.each do |_bc|

      bc = Tdm::BuildConfiguration.new(_bc.attributes)
      _bc.params.each_pair do |k, v|
        bc.params[k] = v
      end
      bc.test_run_id = test_run.id
      bc.output = 'X'
      bc.save!
      _bc.test_configurations.each do |_tc|
        tc = Tdm::TestConfiguration.new(_tc.attributes)
        _tc.params.each_pair do |k, v|
          tc.params[k] = v
        end
        tc.build_configuration_id = bc.id
        tc.save!
        _tc.groups.each do |_g|
          g = Tdm::Group.new(_g.attributes)
          g.test_configuration_id = tc.id
          g.save!
          _g.test_cases.each do |_t|
            t = Tdm::TestCase.new(_t.attributes)
            _t.params.each_pair do |k, v|
              t.params[k] = v
            end
            _t.statistics.each_pair do |k, v|
              t.statistics[k] = v
            end
            t.group_id = g.id
            t.save!
            _t.test_case_executions.each do |_tcr|
              tcr = Tdm::TestCaseExecution.new(_tcr.attributes)
              tcr.test_case_id = t.id
              tcr.output = 'X'
              _tcr.numerical_statistics.each_pair do |k, v|
                tcr.numerical_statistics[k] = v
              end
              _tcr.statistics.each_pair do |k, v|
                tcr.statistics[k] = v
              end
              tcr.save!
            end
          end
        end
      end
    end
    test_run
  end

  def create_test_run_for_perf_tests
    test_run = Tdm::TestRun.find(1)
    test_run.build_configurations[1].destroy
    build_configuration = test_run.build_configurations[0]
    build_configuration.name = 'production'
    build_configuration.save!
    assert_equal(2, build_configuration.test_configurations.size)
    build_configuration.test_configurations[1].destroy

    test_configuration = build_configuration.test_configurations[0]
    test_configuration.name = 'Performance'
    test_configuration.params['mode'] = 'performance'
    test_configuration.save!
    assert_equal(2, test_configuration.groups.size)
    group = test_configuration.groups[1]
    group.name = 'SPECjvm98'
    group.save!
    assert_equal(2, group.test_cases.size)
    group.test_cases[1].destroy
    group.test_cases[0].name = 'SPECjvm98'
    group.test_cases[0].statistics.clear
    group.test_cases[0].statistics['aggregate.best.score'] = '412'
    group.test_cases[0].save!

    group = test_configuration.groups[0]
    group.name = 'SPECjbb2005'
    group.save!
    assert_equal(2, group.test_cases.size)
    group.test_cases[1].destroy
    group.test_cases[0].name = 'SPECjbb2005'
    group.test_cases[0].statistics.clear
    group.test_cases[0].statistics['score'] = '22'
    group.test_cases[0].save!

    test_run = Tdm::TestRun.find(1)
    assert_equal(1, test_run.build_configurations.size)
    assert_equal('production', test_run.build_configurations[0].name)
    assert_equal(1, test_run.build_configurations[0].test_configurations.size)
    assert_equal('Performance', test_run.build_configurations[0].test_configurations[0].name)
    assert_equal(2, test_run.build_configurations[0].test_configurations[0].groups.size)

    assert_equal('SPECjbb2005', test_run.build_configurations[0].test_configurations[0].groups[0].name)
    assert_equal(1, test_run.build_configurations[0].test_configurations[0].groups[0].test_cases.size)
    assert_equal('SPECjbb2005', test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0].name)

    assert_equal('SPECjvm98', test_run.build_configurations[0].test_configurations[0].groups[1].name)
    assert_equal(1, test_run.build_configurations[0].test_configurations[0].groups[1].test_cases.size)
    assert_equal('SPECjvm98', test_run.build_configurations[0].test_configurations[0].groups[1].test_cases[0].name)

    Tdm::TestRun.find(1)
  end
end
