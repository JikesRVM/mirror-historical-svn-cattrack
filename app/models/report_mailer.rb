class ReportMailer < ActionMailer::Base

  helper ApplicationHelper
  helper PresentationHelper
  helper ReportMailerHelper
  helper Results::TestRunHelper

  def report(test_run)
    report = Report::RegressionReport.new(test_run)
    error_count = report.test_run.test_cases.size - report.test_run.successes.size

    subject((error_count == 0) ? 'SUCCESS' : "#{error_count} FAILURE#{(error_count == 1) ? '' : 'S'}")
    b = {"host" => test_run.host, "test_run" => test_run, "report" => report}
    body(b)
    reply_to = SystemSetting['report.reply.to']
    headers({'Reply-To' => reply_to}) if reply_to
    recipients(SystemSetting['report.mail.to'])
    f = "\"[#{test_run.build_target.name}][#{test_run.variant}]\" <#{SystemSetting['mail.from']}>"
    from(f)
    content_type("text/html")
  end
end
