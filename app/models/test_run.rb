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
class TestRun < ActiveRecord::Base
  has_many :build_runs, :through => :test_configurations, :uniq => true, :dependent => :destroy

  TESTCASE_SQL_PREFIX = <<-END_SQL
   SELECT test_cases.*
   FROM test_runs
   LEFT OUTER JOIN test_configurations ON test_configurations.test_run_id = test_runs.id
   LEFT OUTER JOIN build_runs ON build_runs.id = test_configurations.build_run_id
   LEFT OUTER JOIN build_configurations ON build_configurations.id = build_runs.build_configuration_id
   LEFT OUTER JOIN groups ON groups.test_configuration_id = test_configurations.id
   LEFT OUTER JOIN test_cases ON test_cases.group_id = groups.id
   WHERE test_runs.id = \#{id}
  END_SQL

  def self.test_case_rel(name, sql = nil)
    common_sql = sql.nil? ? TESTCASE_SQL_PREFIX : TESTCASE_SQL_PREFIX + ' AND ' + sql
    finder_sql = common_sql
    counter_sql = "SELECT COUNT(*) FROM (#{common_sql}) f"
    has_many name, :class_name => 'TestCase', :finder_sql => finder_sql, :counter_sql => counter_sql
  end

  test_case_rel :successes, "test_cases.result = 'SUCCESS'"
  test_case_rel :failures, "test_cases.result = 'FAILURE'"
  test_case_rel :excludes, "test_cases.result = 'EXCLUDED'"
  test_case_rel :test_cases

  validates_positive :revision

  def parent_node
    host
  end

  def self.create_from(host_name, filename, user, upload_time)
    # TODO: de-gzip if required
    # TODO: Validate xml against a schema
    transaction do
      host = Host.find_or_create_by_name(host_name)

      test_run = TestRun.new
      test_run.host = host
      test_run.uploader = user
      test_run.uploaded_at = upload_time

      xml = REXML::Document.new(File.open(filename))
      test_run.name = xml.elements['/report/id'].text
      test_run.revision = xml.elements['/report/revision'].text.to_i
      test_run.occured_at = Time.parse(xml.elements['/report/time'].text)
      test_run.save!

      target_run_name = xml.elements["/report/target/parameters/parameter[@key = 'target.name']/@value"].value

      build_target = BuildTarget.new(:name => target_run_name)
      xml.elements.each("/report/target/parameters/parameter[@key != 'target.name']") do |p_xml|
        build_target.params[p_xml.attributes['key']] = p_xml.attributes['value']
      end
      test_run.build_target = build_target
      build_target.test_run = test_run
      build_target.save!

      configs = {}
      xml.elements.each('/report/configuration') do |c_xml|
        build_configuration_name = c_xml.elements['id'].text
        build_configuration = BuildConfiguration.new(:name => build_configuration_name)
        c_xml.elements.each("parameters/parameter[@key != 'config.name']") do |p_xml|
          build_configuration.params[p_xml.attributes['key']] = p_xml.attributes['value']
        end
        build_configuration.save!
        configs[build_configuration_name] = build_configuration
      end

      build_runs ={}
      xml.elements.each('/report/builds/build') do |b_xml|
        build_run = BuildRun.new
        build_run.build_configuration = configs[b_xml.elements['configuration'].text]
        build_run.time = b_xml.elements['time'].text.to_i
        build_run.result = b_xml.elements['result'].text
        build_run.output = b_xml.elements['output'].text
        build_run.save!
        build_runs[build_run.build_configuration.name] = build_run
      end

      xml.elements.each('/report/configuration') do |c_xml|
        build_run = build_runs[c_xml.elements['id'].text]
        c_xml.elements.each('test-configuration') do |tc_xml|
          test_configuration = TestConfiguration.new
          test_configuration.test_run = test_run
          test_configuration.build_run = build_run
          test_configuration.name = tc_xml.elements['id'].text
          tc_xml.elements.each("parameters/parameter") do |p_xml|
            test_configuration.params[p_xml.attributes['key']] = p_xml.attributes['value']
          end
          test_configuration.save!

          tc_xml.elements.each('test-group') do |g_xml|
            group = Group.new
            group.test_configuration = test_configuration
            group.name = g_xml.elements['id'].text
            group.save!

            g_xml.elements.each('test') do |t_xml|
              test_case = TestCase.new
              test_case.group = group
              test_case.name = t_xml.elements['id'].text
              test_case.classname = t_xml.elements['class'].text
              test_case.args = t_xml.elements['args'].text
              test_case.args = "" if test_case.args.nil?
              test_case.working_directory = t_xml.elements['working-directory'].text
              test_case.command = t_xml.elements['command'].text
              test_case.exit_code = t_xml.elements['exit-code'].text.to_i
              test_case.time = t_xml.elements['time'].text.to_i
              test_case.result = t_xml.elements['result'].text
              test_case.result_explanation = t_xml.elements['result-explanation'].text
              test_case.result_explanation = "" if test_case.result_explanation.nil?
              test_case.output = t_xml.elements['output'].text

              t_xml.elements.each("rvm-parameters/parameter") do |p_xml|
                test_case.params[p_xml.attributes['key']] = p_xml.attributes['value']
              end

              t_xml.elements.each("statistics/statistic") do |p_xml|
                test_case.statistics[p_xml.attributes['key']] = p_xml.attributes['value']
              end

              test_case.save!
            end
          end
        end
      end

      test_run
    end
  end
end
