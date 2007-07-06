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

  def test_link(row, only_path = true)
    options = {:controller => "/results/test_case", :action => 'show'}
    options[:host_name] = @report.test_run.host.name
    options[:test_run_variant] = @report.test_run.variant
    options[:test_run_id] = @report.test_run.id
    options[:build_configuration_name] = row['build_configuration_name']
    options[:test_configuration_name] = row['test_configuration_name']
    options[:group_name] = row['group_name']
    options[:test_case_name] = row['test_case_name']
    options[:only_path] = only_path

    link_to('Show', options)
  end

  def perf_stat(test_run_id, row)
    str_value = row["test_run_#{test_run_id}"]
    return '' unless str_value
    value = Kernel.Float(str_value)
    std_deviation = row["std_deviation"] ? Kernel.Float(row["std_deviation"]) : 0
    best_score = row["best_score"] ? Kernel.Float(row["best_score"]) : 0
    style = nil
    render_map = ['color: green; font-weight: bold;','color: green;','', 'color: red;','color: red; font-weight: bold;']
    render_limits = [0.0, 0.8, 1.6, 2.4, 3].collect {|r| r*std_deviation }

    if row["less_is_more"] == '1'
      if value == best_score
        style = render_map[0]
      elsif value < (best_score + render_limits[1])
        style = render_map[1]
      elsif value < (best_score + render_limits[2])
        include_suffix = true
        style = render_map[2]
      elsif value < (best_score + render_limits[3])
        include_suffix = true
        style = render_map[3]
      else
        include_suffix = true
        style = render_map[4]
      end
    else
      if value == best_score
        style = render_map[0]
      elsif value > (best_score - render_limits[1])
        style = render_map[1]
      elsif value > (best_score - render_limits[2])
        include_suffix = true
        style = render_map[2]
      elsif value > (best_score - render_limits[3])
        include_suffix = true
        style = render_map[3]
      else
        include_suffix = true
        style = render_map[4]
      end
    end
    suffix = ''
    if include_suffix
      change = ((value-best_score)/best_score*100).to_i
      suffix = " (#{(change > 0) ? '+':''}#{change}%)"
    end
    "<span style=\"#{style}\">#{str_value}#{suffix}</span>"
  end
end
