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
class BuilderException < Exception
end

# Utility class for building TestRun from an xml file.
class TestRunBuilder
  cattr_accessor :logger

  def self.create_from(host_name, filename)
    logger.info("Importing test run from host '#{host_name}' defined in file #{filename}")

    #TODO: Validate xml against a schema
    test_run = TestRun.new
    test_run.host = Host.find_or_create_by_name(host_name)
    file = Zlib::GzipReader.open(filename) if filename =~ /\.gz$/
    file = File.open(filename) unless file

    TestRun.transaction do
      xml = REXML::Document.new(file)

      test_run_name = xml.elements['/report/id'].text
      begin
        test_run.name = test_run_name
        test_run.revision = xml.elements['/report/revision'].text.to_i
        test_run.occured_at = Time.parse(xml.elements['/report/time'].text).getutc
        save!(test_run)
        test_run_id = test_run.id
        test_run = nil

        configs = build_build_configurations(xml, test_run_id)
        build_build_target(xml, test_run_id)

        logger.debug("TestRun #{test_run_name} contains #{configs.size} build configurationss. Starting to process test configurations.")

        build_test_configurations(xml, configs)

        TestRun.find(test_run_id)
      rescue Object => e
        logger.debug("TestRun #{test_run_name} caused an error #{e.message}.")
        raise e
      ensure
        file.close
      end
    end
  end

  private

  def self.build_build_target(xml, test_run_id)
    target_element = xml.elements["/report/target/parameters/parameter[@key = 'target.name']/@value"]
    raise BuilderException.new("Missing target name. Likely all builds failed.") unless target_element
    target_run_name = target_element.value

    build_target = BuildTarget.new(:name => target_run_name)
    xml.elements.each("/report/target/parameters/parameter[@key != 'target.name']") do |p_xml|
      build_target.params[p_xml.attributes['key']] = p_xml.attributes['value']
    end
    build_target.test_run_id = test_run_id
    save!(build_target)
  end

  def self.build_build_configurations(xml, test_run_id)
    configs = {}
    xml.elements.each('/report/configuration') do |c_xml|
      build_configuration_name = c_xml.elements['id'].text
      build_configuration = BuildConfiguration.new(:name => build_configuration_name)
      c_xml.elements.each("parameters/parameter[@key != 'config.name']") do |p_xml|
        build_configuration.params[p_xml.attributes['key']] = p_xml.attributes['value']
      end
      build_configuration.test_run_id = test_run_id
      configs[build_configuration_name] = build_configuration
    end
    xml.elements.each('/report/builds/build') do |b_xml|
      configuration_name = b_xml.elements['configuration'].text
      build_configuration = configs[configuration_name]
      raise BuilderException.new("Missing build_run. Builds likely failed.") unless build_configuration
      build_configuration.time = b_xml.elements['time'].text.to_i
      build_configuration.result = b_xml.elements['result'].text
      build_configuration.output = b_xml.elements['output'].text
      save!(build_configuration)
      configs[configuration_name] = build_configuration.id
    end

    configs
  end

  def self.build_test_configurations(xml, configs)
    xml.elements.each('/report/configuration') do |c_xml|
      build_configuration_name = c_xml.elements['id'].text
      build_configuration_id = configs[build_configuration_name]
      c_xml.elements.each('test-configuration') do |tc_xml|

        test_configuration_name = tc_xml.elements['id'].text
        logger.debug("Processing test configuration for '#{test_configuration_name}' using build configuration '#{build_configuration_name}'.")

        test_configuration = TestConfiguration.new
        test_configuration.build_configuration_id = build_configuration_id
        test_configuration.name = test_configuration_name
        tc_xml.elements.each("parameters/parameter") do |p_xml|
          test_configuration.params[p_xml.attributes['key']] = p_xml.attributes['value']
        end
        save!(test_configuration)

        tc_xml.elements.each('test-group') do |g_xml|
          build_group(g_xml, test_configuration.id)
        end
      end
    end
  end

  def self.build_group(xml, test_configuration_id)
    group = Group.new
    group.test_configuration_id = test_configuration_id
    group.name = xml.elements['id'].text
    save!(group)
    logger.debug("Processing group #{group.name}.")

    xml.elements.each('test') do |t_xml|
      build_test_case(t_xml, group.id)
    end
  end

  def self.build_test_case(xml, group_id)
    test_name = xml.elements['id'].text
    logger.debug("Processing test #{test_name}.")
    test_case = TestCase.new
    test_case.group_id = group_id
    test_case.name = test_name
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
      puts object.to_xml
      raise e
    end
  end
end
