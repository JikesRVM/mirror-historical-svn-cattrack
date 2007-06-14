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
require File.dirname(__FILE__) + '/../test_helper'

class TestRunImporterTest < Test::Unit::TestCase

  def setup
    @results_dir = "#{File.expand_path(RAILS_ROOT)}/tmp/importer_test"
    SystemSetting['results.dir'] = @results_dir
    FileUtils.mkdir_p @results_dir
    @host = "rvmx86lnx64.anu.edu.au"
    @host_dir = "#{@results_dir}/incoming/#{@host}"
    FileUtils.mkdir_p @host_dir
  end

  def teardown
    FileUtils.rm_rf @results_dir
  end

  def test_results_dir_missing
    SystemSetting.find_by_name('results.dir').destroy
    assert_raises(ImportException) { TestRunImporter.process_incoming_test_runs }
  end

  def test_process_empty_dir
    initial = Tdm::TestRun.count
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial, Tdm::TestRun.count)
  end

  def test_process_with_non_matching_file
    initial = Tdm::TestRun.count
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/Report.xml.gz", "#{@host_dir}/foo.bar.baz"
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial, Tdm::TestRun.count)
  end

  def test_process_a_single_successful_file
    initial = Tdm::TestRun.count
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/Report.xml.gz", "#{@host_dir}/Report.xml.gz"
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial + 1, Tdm::TestRun.count)
    assert_equal(true, File.exist?("#{@results_dir}/processed/#{@host}/Report.xml.gz"))
    assert_equal(false, File.exist?("#{@results_dir}/failed/#{@host}/Report.xml.gz"))
  end

  def test_process_a_single_file_that_is_too_large
    initial = Tdm::TestRun.count
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/HugeReport.xml.gz", "#{@host_dir}/Report.xml.gz"
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial, Tdm::TestRun.count)
    assert_equal(false, File.exist?("#{@results_dir}/processed/#{@host}/Report.xml.gz"))
    assert_equal(true, File.exist?("#{@results_dir}/failed/#{@host}/Report.xml.gz"))
  end

  def test_process_a_single_successful_file
    initial = Tdm::TestRun.count
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/Report.xml.gz", "#{@host_dir}/Report.xml.gz"
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial + 1, Tdm::TestRun.count)
    assert_equal(true, File.exist?("#{@results_dir}/processed/#{@host}/Report.xml.gz"))
    assert_equal(false, File.exist?("#{@results_dir}/failed/#{@host}/Report.xml.gz"))
  end

  def test_process_multiple_files
    initial = Tdm::TestRun.count
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/Report.xml.gz", "#{@host_dir}/Report.xml.gz"
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/HugeReport.xml.gz", "#{@host_dir}/HugeReport.xml.gz"
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial + 1, Tdm::TestRun.count)
    assert_equal(true, File.exist?("#{@results_dir}/processed/#{@host}/Report.xml.gz"))
    assert_equal(true, File.exist?("#{@results_dir}/failed/#{@host}/HugeReport.xml.gz"))
  end

end
