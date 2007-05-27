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

# Utility class for building TestRun from an xml file.
class TestRunBuilder
  def self.create_from(host_name, filename, user, upload_time)
    # TODO: Validate xml against a schema
    TestRun.transaction do
      test_run = TestRun.new
      test_run.host = Host.find_or_create_by_name(host_name)
      test_run.uploader = user
      test_run.uploaded_at = upload_time
      file = Zlib::GzipReader.open(filename) if filename =~ /\.gz$/
      file = File.open(filename) unless file

      xml = REXML::Document.new(file)

      test_run.name = xml.elements['/report/id'].text
      test_run.revision = xml.elements['/report/revision'].text.to_i
      test_run.occured_at = Time.parse(xml.elements['/report/time'].text)
      save!(test_run)

      build_build_target(xml, test_run)

      configs = build_build_configurations(xml)
      build_runs = build_build_runs(xml, configs)
      build_test_configurations(xml, test_run, build_runs)

      test_run
    end
  end

  private

  def self.build_build_target(xml, test_run)
    target_run_name = xml.elements["/report/target/parameters/parameter[@key = 'target.name']/@value"].value

    build_target = BuildTarget.new(:name => target_run_name)
    xml.elements.each("/report/target/parameters/parameter[@key != 'target.name']") do |p_xml|
      build_target.params[p_xml.attributes['key']] = p_xml.attributes['value']
    end
    test_run.build_target = build_target
    build_target.test_run = test_run
    save!(build_target)
  end

  def self.build_build_configurations(xml)
    configs = {}
    xml.elements.each('/report/configuration') do |c_xml|
      build_configuration_name = c_xml.elements['id'].text
      build_configuration = BuildConfiguration.new(:name => build_configuration_name)
      c_xml.elements.each("parameters/parameter[@key != 'config.name']") do |p_xml|
        build_configuration.params[p_xml.attributes['key']] = p_xml.attributes['value']
      end
      save!(build_configuration)
      configs[build_configuration_name] = build_configuration
    end

    configs
  end

  def self.build_build_runs(xml, configs)
    build_runs = {}
    xml.elements.each('/report/builds/build') do |b_xml|
      build_run = BuildRun.new
      build_run.build_configuration = configs[b_xml.elements['configuration'].text]
      build_run.time = b_xml.elements['time'].text.to_i
      build_run.result = b_xml.elements['result'].text
      build_run.output = b_xml.elements['output'].text
      save!(build_run)
      build_runs[build_run.build_configuration.name] = build_run
    end
    build_runs
  end

  def self.build_test_configurations(xml, test_run, build_runs)
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
        save!(test_configuration)

        tc_xml.elements.each('test-group') do |g_xml|
          build_group(g_xml, test_configuration)
        end
      end
    end
  end

  def self.build_group(xml, test_configuration)
    group = Group.new
    group.test_configuration = test_configuration
    group.name = xml.elements['id'].text
    save!(group)

    xml.elements.each('test') do |t_xml|
      build_test_case(t_xml, group)
    end
  end

  def self.build_test_case(xml, group)
    test_case = TestCase.new
    test_case.group = group
    test_case.name = xml.elements['id'].text
    test_case.classname = xml.elements['class'].text
    test_case.args = xml.elements['args'].text
    test_case.args = "" if test_case.args.nil?
    test_case.working_directory = xml.elements['working-directory'].text
    test_case.command = xml.elements['command'].text
    test_case.exit_code = xml.elements['exit-code'].text.to_i
    test_case.time = xml.elements['time'].text.to_i
    test_case.result = xml.elements['result'].text
    test_case.result_explanation = xml.elements['result-explanation'].text
    test_case.result_explanation = "" if test_case.result_explanation.nil?
    test_case.output = xml.elements['output'].text
    test_case.output = "" if test_case.output.nil?

    xml.elements.each("rvm-parameters/parameter") do |p_xml|
      test_case.params[p_xml.attributes['key']] = p_xml.attributes['value']
    end

    xml.elements.each("statistics/statistic") do |p_xml|
      test_case.statistics[p_xml.attributes['key']] = p_xml.attributes['value']
    end

    save!(test_case)
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
