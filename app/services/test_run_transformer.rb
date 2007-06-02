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
      build_target = create_build_target(test_run.build_target)
      revision = RevisionDimension.find_or_create_by_revision(test_run.revision)

      time = create_time(test_run.occured_at)
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

  def self.create_time(t)
    params = {}
    params[:year] = t.year
    params[:month] = t.month
    params[:week] = t.strftime('%W').to_i + 1
    params[:day_of_year] = t.yday
    params[:day_of_month] = t.mday
    params[:day_of_week] = t.wday + 1
    params[:time] = t
    find_or_create(TimeDimension,params)
  end

  def self.create_build_target(bt)
    p = bt.params
    params = {}
    params[:name] = bt.name
    params[:arch] = p['target.arch']
    params[:address_size] = p['target.address.size'].to_i
    params[:operating_system] = p['target.os']
    find_or_create(BuildTargetDimension,params)
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
    find_or_create(BuildConfigurationDimension,params)
  end

  def self.find_or_create(model,params)
    conditions = [params.keys.collect {|k| "#{k} = :#{k}"}.join(' AND '), params]
    object = model.find(:first,:conditions => conditions)
    return object if object
    model.create!(params)
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

    statistic = StatisticDimension.find_or_create_by_name('rvm.real.time')
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
    sfact.statistic = statistic
    sfact.value = t.time
    save!(sfact)

    t.statistics.each_pair do |k, v|
      begin
        Kernel.Float(v)
      rescue ArgumentError, TypeError
        next
      end
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
      sfact.statistic = statistic
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
