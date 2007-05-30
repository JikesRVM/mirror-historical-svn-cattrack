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

# Utility class that transforms a test-run from OLTP to OLAP schemas
class TestRunTransformer
  def self.build_olap_model_from(test_run)
    TestRun.transaction do
      host = HostDimension.find_or_create_by_name(test_run.host.name)
      tr = TestRunDimension.create!(:source_id => test_run.id, :name => test_run.name)
      p = test_run.build_target.params
      build_target = BuildTargetDimension.
        find_or_create_by_name_and_arch_and_address_size_and_operating_system(test_run.build_target.name,
                                                                              p['target.arch'] || 'Unknown',
                                                                              p['target.address.size'].to_i || 32,
                                                                              p['target.os'].to_i || 'Unknown')
      revision = RevisionDimension.find_or_create_by_revision(test_run.revision)

      t = test_run.occured_at
      time =
        TimeDimension.find_or_create_by_year_and_month_and_week_and_day_of_year_and_day_of_month_and_day_of_week_and_time(t.year,
                                                                                                                 t.strftime('%b'),
                                                                                                                 t.strftime('%W').to_i,
                                                                                                                 t.yday,
                                                                                                                 t.mday,
                                                                                                                 t.strftime('%a'),
                                                                                                                 t)
      test_run.test_configurations.each do |tc|
        test_configuration = create_test_configuration(tc)
        build_configuration = create_build_configuration(tc.build_run.build_configuration)
        tc.groups.each do |g|
          g.test_cases.each do |t|
            create_test(host, tr, build_target, revision, time, test_configuration, build_configuration, g.name, t)
          end
        end
      end
    end
  end

  private

  def self.create_test_configuration(tc)
    TestConfigurationDimension.find_or_create_by_name_and_mode(tc.name,tc.params['mode'] || '')
  end

  def self.create_build_configuration(bc)
    p = bc.params
    args = [bc.name, p['config.bootimage.compiler'], p['config.runtime.compiler'], p['config.mmtk.plan'], p['config.assertions'], (p['config.include.all-classes'] == 'false') ? 'minimal' : 'complete' ]
    BuildConfigurationDimension.find_or_create_by_name_and_bootimage_compiler_and_runtime_compiler_and_mmtk_plan_and_assertion_level_and_bootimage_class_inclusion_policy(*args)
  end

  def self.create_test(host, test_run, build_target, revision, time, test_configuration, build_configuration, group_name, t)
    tc = TestCaseDimension.find_or_create_by_name_and_group(t.name,group_name)
    result = ResultDimension.find_or_create_by_name(t.result)
    rfact = ResultFact.new
    rfact.host = host
    rfact.test_run = test_run
    rfact.build_configuration = build_configuration
    rfact.test_configuration = test_configuration
    rfact.build_target = build_target
    rfact.test_case = tc
    rfact.time = time
    rfact.revision = revision
    rfact.source = t
    rfact.result = result
    save!(rfact)

    t.statistics.each_pair do |k, v|
      next unless (v =~ /\A[+-]?\d+\Z/)
      statistic = StatisticDimension.find_or_create_by_name(k)
      sfact = StatisticFact.new
      sfact.host = host
      sfact.test_run = test_run
      sfact.build_configuration = build_configuration
      sfact.test_configuration = test_configuration
      sfact.build_target = build_target
      sfact.test_case = tc
      sfact.time = time
      sfact.revision = revision
      sfact.source = t
      sfact.value = v.to_i
      save!(sfact)
    end
  end

  def self.save!(object)
    begin
      object.save!
    rescue => e
      object.to_xml
      raise e
    end
  end
end
