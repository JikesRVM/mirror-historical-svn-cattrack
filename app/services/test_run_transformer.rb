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
    Tdm::TestRun.transaction do
      host = Olap::HostDimension.find_or_create_by_name(test_run.host.name)
      tr = Olap::TestRunDimension.create!(:source_id => test_run.id, :name => test_run.name)
      build_target = create_build_target(test_run.build_target)
      revision = Olap::RevisionDimension.find_or_create_by_revision(test_run.revision)

      time = create_time(test_run.occurred_at)
      test_run.build_configurations.each do |bc|
        # Do not try and process build_configuration with zero test_configurations
        # as the build has failed and has invalid set of properties
        next unless bc.test_configurations.size > 0
        build_configuration = create_build_configuration(bc)
        bc.test_configurations.each do |tc|
          test_configuration = create_test_configuration(tc)
          tc.groups.each do |g|
            g.test_cases.each do |t|
              create_test(host, tr, build_target, revision, time, test_configuration, build_configuration, g.name, t)
            end
          end
        end
      end
      AuditLog.log('olap.import.test-run', tr)
    end
  end

  private

  def self.create_test_configuration(tc)
    Olap::TestConfigurationDimension.find_or_create_by_name_and_mode(tc.name, tc.params['mode'] || '')
  end

  def self.create_time(t)
    params = {}
    params[:year] = t.year
    params[:month] = t.month
    params[:week] = t.strftime('%W').to_i + 1
    params[:day_of_year] = t.yday
    params[:day_of_month] = t.mday
    params[:day_of_week] = t.wday + 1
    params[:time] = t
    find_or_create(Olap::TimeDimension, params)
  end

  def self.create_build_target(bt)
    p = bt.params
    params = {}
    params[:name] = bt.name
    params[:arch] = p['target.arch']
    params[:address_size] = p['target.address.size'].to_i
    params[:operating_system] = p['target.os']
    find_or_create(Olap::BuildTargetDimension, params)
  end

  def self.create_build_configuration(bc)
    p = bc.params
    params = {}
    params[:name] = bc.name
    params[:bootimage_compiler] = p['config.bootimage.compiler']
    params[:runtime_compiler] = p['config.runtime.compiler']
    params[:mmtk_plan] = p['config.mmtk.plan']
    params[:assertion_level] = p['config.assertions']
    params[:bootimage_class_inclusion_policy] = (p['config.include.all-classes'] == 'false') ? 'minimal' : 'complete'
    find_or_create(Olap::BuildConfigurationDimension, params)
  end

  def self.find_or_create(model, params)
    conditions = [params.keys.collect {|k| "#{k} = :#{k}"}.join(' AND '), params]
    object = model.find(:first, :conditions => conditions)
    return object if object
    model.create!(params)
  end

  def self.create_test(host, test_run, build_target, revision, time, test_configuration, build_configuration, group_name, t)
    tc = Olap::TestCaseDimension.find_or_create_by_name_and_group(t.name, group_name)
    result = Olap::ResultDimension.find_or_create_by_name(t.result)
    rfact = Olap::ResultFact.new
    rfact.host_id = host.id
    rfact.test_run_id = test_run.id
    rfact.build_configuration_id = build_configuration.id
    rfact.test_configuration_id = test_configuration.id
    rfact.build_target_id = build_target.id
    rfact.test_case_id = tc.id
    rfact.time_id = time.id
    rfact.revision_id = revision.id
    rfact.source_id = t.id
    rfact.result_id = result.id
    save!(rfact)

    statistic = Olap::StatisticDimension.find_or_create_by_name('rvm.real.time')
    sfact = Olap::StatisticFact.new
    sfact.host_id = host.id
    sfact.test_run_id = test_run.id
    sfact.build_configuration_id = build_configuration.id
    sfact.test_configuration_id = test_configuration.id
    sfact.build_target_id = build_target.id
    sfact.test_case_id = tc.id
    sfact.time_id = time.id
    sfact.revision_id = revision.id
    sfact.source_id = t.id
    sfact.statistic_id = statistic.id
    sfact.result_id = result.id
    sfact.value = t.time
    save!(sfact)

    t.statistics.each_pair do |k, v|
      begin
        Kernel.Float(v)
      rescue ArgumentError, TypeError
        next
      end
      statistic = Olap::StatisticDimension.find_or_create_by_name(k)
      sfact = Olap::StatisticFact.new
      sfact.host_id = host.id
      sfact.test_run_id = test_run.id
      sfact.build_configuration_id = build_configuration.id
      sfact.test_configuration_id = test_configuration.id
      sfact.build_target_id = build_target.id
      sfact.test_case_id = tc.id
      sfact.time_id = time.id
      sfact.revision_id = revision.id
      sfact.source_id = t.id
      sfact.statistic_id = statistic.id
      sfact.result_id = result.id
      sfact.value = Kernel.Float(v)
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
