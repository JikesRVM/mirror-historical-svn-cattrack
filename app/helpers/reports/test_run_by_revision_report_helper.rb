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
module Reports::TestRunByRevisionReportHelper

  def hide_tests_javascript(name)
    "Element.toggle('#{name}'); Element.toggleClassName('#{name}_toggle','open')"
  end

  def tests_header(name, label)
    "<a href=\"#\" id=\"#{name}_toggle\" class=\"toggle_visibility open\" onclick=\"#{hide_tests_javascript(name)}; return false;\">#{label}</a>"
  end

  def test_link(row)
    options = {:controller => "/results/test_case", :action => 'show'}
    options[:host_name] = @report.test_run.host.name
    options[:test_run_variant] = @report.test_run.variant
    options[:test_run_id] = @report.test_run.id
    options[:build_configuration_name] = row['build_configuration_name']
    options[:test_configuration_name] = row['test_configuration_name']
    options[:group_name] = row['group_name']
    options[:test_case_name] = row['test_case_name']

    link_to('Show', options)
  end
end
