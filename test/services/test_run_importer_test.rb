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
    purge_log
    assert_raises(ImportException) { TestRunImporter.process_incoming_test_runs }
    assert_logs([])
  end

  def test_process_empty_dir
    purge_log
    initial = Tdm::TestRun.count
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial, Tdm::TestRun.count)
    assert_logs([["import.started", ""], ["import.host", "rvmx86lnx64.anu.edu.au"], ["import.completed", ""]])
  end

  def test_process_with_non_matching_file
    purge_log
    initial = Tdm::TestRun.count
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/Report.xml.gz", "#{@host_dir}/foo.bar.baz"
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial, Tdm::TestRun.count)
    assert_logs([["import.started", ""], ["import.host", "rvmx86lnx64.anu.edu.au"], ["import.completed", ""]])
  end

  def test_process_a_single_successful_file
    purge_log
    initial = Tdm::TestRun.count
    filename = "#{@host_dir}/Report.xml.gz"
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/Report.xml.gz", filename
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial + 1, Tdm::TestRun.count)
    assert_equal(true, File.exist?("#{@results_dir}/processed/#{@host}/Report.xml.gz"))
    assert_equal(false, File.exist?("#{@results_dir}/failed/#{@host}/Report.xml.gz"))
    assert_logs([["import.started", ""],
    ["import.host", "rvmx86lnx64.anu.edu.au"],
    ["import.file.started", filename],
    ["olap.import.test-run", "id=2 (tiny)"],
    ["import.file.success", filename],
    ["import.completed", ""]])
  end

  def test_process_a_single_file_that_is_too_large
    purge_log
    initial = Tdm::TestRun.count
    filename = "#{@host_dir}/Report.xml.gz"
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/HugeReport.xml.gz", filename
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial, Tdm::TestRun.count)
    assert_equal(false, File.exist?("#{@results_dir}/processed/#{@host}/Report.xml.gz"))
    assert_equal(true, File.exist?("#{@results_dir}/failed/#{@host}/Report.xml.gz"))
    assert_logs([["import.started", ""],
    ["import.host", "rvmx86lnx64.anu.edu.au"],
    ["import.file.started", filename],
    ["import.file.error", "Failed to process file #{filename} due to Unzipping #{filename} produced too large a file 114381038"],
    ["import.completed", ""]])
  end

  def test_process_multiple_files
    purge_log
    initial = Tdm::TestRun.count
    sfilename = "#{@host_dir}/Report.xml.gz"
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/Report.xml.gz", sfilename
    hfilename = "#{@host_dir}/HugeReport.xml.gz"
    FileUtils.cp "#{RAILS_ROOT}/test/fixtures/data/HugeReport.xml.gz", hfilename
    TestRunImporter.process_incoming_test_runs
    assert_equal(initial + 1, Tdm::TestRun.count)
    assert_equal(true, File.exist?("#{@results_dir}/processed/#{@host}/Report.xml.gz"))
    assert_equal(true, File.exist?("#{@results_dir}/failed/#{@host}/HugeReport.xml.gz"))
    assert_logs([["import.started", ""],
    ["import.host", "rvmx86lnx64.anu.edu.au"],
    ["import.file.started", hfilename],
    ["import.file.error", "Failed to process file #{hfilename} due to Unzipping #{hfilename} produced too large a file 114381038"],
    ["import.file.started", sfilename],
    ["olap.import.test-run", "id=3 (tiny)"],
    ["import.file.success", sfilename],
    ["import.completed", ""]])
  end
end
