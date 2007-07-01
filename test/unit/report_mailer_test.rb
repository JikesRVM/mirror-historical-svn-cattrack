require File.dirname(__FILE__) + '/../test_helper'

class ReportMailerTest < Test::Unit::TestCase
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.default_url_options = {:host => '127.0.0.1'}
    Olap::ResultFact.destroy_all
    Olap::StatisticFact.destroy_all
  end

  def test_report
    response = ReportMailer.create_report(Tdm::TestRun.find(1))
    assert_equal('SUCCESS', response.subject)
    assert_equal(["peter@realityforge.org"], response.to)
    assert_equal(["rvm-regression@cs.anu.edu.au"], response.from)
    assert_equal("1.0", response.mime_version)
    assert_equal("text/html", response.content_type)
    assert_expected_body('test_report', response.body)
  end

  def test_report_minimal_history_new_successes_and_failures
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_case1 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case1.result = 'OVERTIME'
    test_case1.save!

    test_case2 = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    test_case2.result = 'FAILURE'
    test_case2.save!

    olappy(test_run.id)
    olappy(test_run_1.id)

    response = ReportMailer.create_report(Tdm::TestRun.find(1))
    assert_equal('1 FAILURE', response.subject)
    assert_expected_body('test_report_minimal_history_new_successes_and_failures', response.body)
  end

  def test_report_minimal_history_missing_tests
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_case2 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    assert(test_case2.destroy)

    olappy(Tdm::TestRun.find(1))
    olappy(Tdm::TestRun.find(test_run_1.id))
    response = ReportMailer.create_report(Tdm::TestRun.find(1))
    assert_equal('SUCCESS', response.subject)
    assert_expected_body('test_report_minimal_history_missing_tests', response.body)
  end

  def test_report_minimal_history_consistent_and_intermitent_failures
    test_run = Tdm::TestRun.find(1)
    test_run_1 = clone_test_run(test_run, 10)
    test_run_2 = clone_test_run(test_run, 20)

    test_case1 = test_run.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case1.result = 'OVERTIME'
    test_case1.save!

    test_case2 = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case2.result = 'OVERTIME'
    test_case2.save!

    test_case3 = test_run_2.build_configurations[0].test_configurations[0].groups[0].test_cases[0]
    test_case3.result = 'OVERTIME'
    test_case3.save!

    test_case2b = test_run_1.build_configurations[0].test_configurations[0].groups[0].test_cases[1]
    test_case2b.result = 'FAILURE'
    test_case2b.save!

    test_case_X = test_run_1.build_configurations[0].test_configurations[0].groups[1].test_cases[0]
    test_case_X.result = 'FAILURE'
    test_case_X.save!

    test_case_Y = test_run.build_configurations[0].test_configurations[0].groups[1].test_cases[0]
    test_case_Y.result = 'FAILURE'
    test_case_Y.save!

    olappy(test_run.id)
    olappy(test_run_1.id)
    olappy(test_run_2.id)

    response = ReportMailer.create_report(Tdm::TestRun.find(1))
    assert_equal('2 FAILURES', response.subject)
    assert_expected_body('test_report_minimal_history_consistent_and_intermitent_failures', response.body)
  end

  def test_report_with_perf_stats
    test_run = create_test_run_for_perf_tests
    test_run_1 = clone_test_run(test_run, 10)

    olappy(test_run.id)
    olappy(test_run_1.id)

    response = ReportMailer.create_report(Tdm::TestRun.find(1))
    assert_equal('SUCCESS', response.subject)
    assert_expected_body('test_report_with_perf_stats', response.body)
  end
  private

  def assert_expected_body(action, body)
    write_body(action, body) if false
    assert_equal read_fixture(action), body
  end

  def read_fixture(action)
    IO.readlines("#{RAILS_ROOT}/test/fixtures/report_mailer/#{action}.html").join
  end

  def write_body(name, body)
    File.open("#{name}.html", 'w+') do |f|
      f.write(body)
    end
  end
end
