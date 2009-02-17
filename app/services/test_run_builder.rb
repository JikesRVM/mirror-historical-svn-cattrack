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

  def self.create_from(filename)
    logger.info("Importing test run defined in file #{filename}")

    #TODO: Validate xml against a schema
    file = Zlib::GzipReader.open(filename) if filename =~ /\.gz$/
    file = File.open(filename) unless file

    Tdm::TestRun.transaction do
      xml = REXML::Document.new(file)

      test_run_name = xml.elements['/report/name'].text
      begin
        test_run = Tdm::TestRun.new
        test_run.name = test_run_name
        host_name = xml.elements['/report/host/name'].text
        test_run.host = Tdm::Host.find_or_create_by_name(host_name)
        test_run.variant = xml.elements['/report/variant'].text
        test_run.revision = xml.elements['/report/revision'].text.to_i
        test_run.start_time = Time.parse(xml.elements['/report/start-time'].text).getutc
        test_run.end_time = Time.parse(xml.elements['/report/end-time'].text).getutc

        # TODO: stop ignoring test-run parameters

        save!(test_run)

        test_run_id = test_run.id
        test_run = nil

        xml.elements.each('/report/build-target') do |c_xml|
          build_build_target(c_xml, test_run_id)
        end

        Tdm::TestRun.find(test_run_id)
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
    build_target = Tdm::BuildTarget.new
    build_target.name = xml.elements['name'].text
    xml.elements.each("parameters/parameter") do |p_xml|
      build_target.params[p_xml.attributes['key']] = p_xml.attributes['value']
    end
    build_target.test_run_id = test_run_id
    save!(build_target)

    xml.elements.each('build-configuration') do |c_xml|
      build_build_configuration(c_xml, test_run_id)
    end
  end

  def self.build_build_configuration(xml, test_run_id)
    build_configuration = Tdm::BuildConfiguration.new
    build_configuration.name = xml.elements['name'].text
    xml.elements.each("parameters/parameter") do |p_xml|
      build_configuration.params[p_xml.attributes['key']] = p_xml.attributes['value']
    end
    build_configuration.test_run_id = test_run_id
    build_configuration.time = xml.elements['duration'].text.to_i
    build_configuration.result = xml.elements['result'].text
    build_configuration.output = xml.elements['output'].text
    logger.debug("Processing build configuration '#{build_configuration.name}'.")
    save!(build_configuration)

    xml.elements.each('test-configuration') do |c_xml|
      build_test_configuration(c_xml, build_configuration.id)
    end
  end

  def self.build_test_configuration(xml, build_configuration_id)
    test_configuration = Tdm::TestConfiguration.new
    test_configuration.build_configuration_id = build_configuration_id
    test_configuration.name = xml.elements['name'].text
    xml.elements.each("parameters/parameter") do |p_xml|
      test_configuration.params[p_xml.attributes['key']] = p_xml.attributes['value']
    end
    logger.debug("Processing test configuration '#{test_configuration.name}'.")
    save!(test_configuration)

    xml.elements.each('group') do |g_xml|
      build_group(g_xml, test_configuration.id)
    end
  end

  def self.build_group(xml, test_configuration_id)
    group = Tdm::Group.new
    group.test_configuration_id = test_configuration_id
    group.name = xml.elements['name'].text
    logger.debug("Processing group #{group.name}.")
    save!(group)

    xml.elements.each('test') do |t_xml|
      build_test_case(t_xml, group.id)
    end
  end

  def self.build_test_case(xml, group_id)
    test_case = Tdm::TestCase.new
    test_case.group_id = group_id
    test_case.name = xml.elements['name'].text
    test_case.command = xml.elements['command'].text
    xml.elements.each("parameters/parameter") do |p_xml|
      test_case.params[p_xml.attributes['key']] = p_xml.attributes['value']
    end
    logger.debug("Processing test #{test_case.name}.")
    save!(test_case)

    test_compilation_xml = xml.elements['test-compilation']
    if (test_compilation_xml != nil)
      build_test_case_compilation(test_compilation_xml, test_case.id)
    end

    xml.elements.each('test-execution') do |t_xml|
      build_test_case_execution(t_xml, test_case.id)
    end
  end

  def self.build_test_case_compilation(xml, test_case_id)
    test_case_compilation = Tdm::TestCaseCompilation.new

    test_case_compilation.test_case_id = test_case_id
    test_case_compilation.exit_code = xml.elements['exit-code'].text.to_i
    test_case_compilation.time = xml.elements['duration'].text.to_i
    test_case_compilation.result = xml.elements['result'].text
    test_case_compilation.output = xml.elements['output'].text || ""

    save!(test_case_compilation)
  end

  def self.build_test_case_execution(xml, test_case_id)
    test_case_execution = Tdm::TestCaseExecution.new

    test_case_execution.name = xml.elements['name'].text
    test_case_execution.test_case_id = test_case_id
    test_case_execution.exit_code = xml.elements['exit-code'].text.to_i
    test_case_execution.time = xml.elements['duration'].text.to_i
    test_case_execution.result = xml.elements['result'].text
    test_case_execution.result_explanation = xml.elements['result-explanation'].text || ""
    test_case_execution.output = xml.elements['output'].text || ""

    xml.elements.each("statistics/statistic") do |p_xml|
      v = p_xml.attributes['value']
      begin
        test_case_execution.num_stats[p_xml.attributes['key']] = Kernel.Float(v)
      rescue ArgumentError, TypeError
        test_case_execution.statistics[p_xml.attributes['key']] = v
      end
    end if test_case_execution.result == 'SUCCESS'

    save!(test_case_execution)
  end

  def self.save!(object)
    begin
      object.save!
    rescue => e
      logger.debug("Error saving object:#{object.to_xml}")
      raise e
    end
  end
end
