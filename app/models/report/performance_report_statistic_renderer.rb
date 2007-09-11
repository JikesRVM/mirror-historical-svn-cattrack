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
class Report::PerformanceReportStatisticRenderer

  def initialize(test_run, statistic_key)
    @test_run = test_run
    @statistic_key = statistic_key
  end

  def get_limits()
    oldest_sql = <<SQL
SELECT
    date_part('epoch', (select start_time from test_runs where id = '#{@test_run.id}') - MIN(test_runs.start_time)) AS oldest
FROM
    test_runs,
    hosts
WHERE
    hosts.name = '#{@test_run.host.name}' AND
    test_runs.variant = '#{@test_run.variant}' AND
    test_runs.start_time <= '#{@test_run.start_time}' AND
    test_runs.host_id = hosts.id
SQL
    limits_sql = <<SQL
SELECT
    (CASE WHEN less_is_more = true THEN 1 ELSE 0 END) AS less_is_more,
    (CASE WHEN less_is_more = true THEN MAX(value) ELSE MIN(value) END) AS worst,
    (CASE WHEN less_is_more = true THEN MIN(value) ELSE MAX(value) END) AS best,
    stddev(value) AS std_dev,
    (#{oldest_sql}) AS oldest
FROM
    test_cases,
    test_case_statistics,
    groups,
    test_configurations,
    build_configurations,
    test_runs,
    hosts,
    statistics_map
WHERE
    hosts.name = '#{@test_run.host.name}' AND
    test_runs.variant = '#{@test_run.variant}' AND
    test_runs.start_time <= '#{@test_run.start_time}' AND
    statistics_map.label = '#{@statistic_key}' AND
    test_case_statistics.owner_id = test_cases.id AND
    test_cases.group_id = groups.id AND
    groups.test_configuration_id = test_configurations.id AND
    test_configurations.build_configuration_id = build_configurations.id AND
    build_configurations.test_run_id = test_runs.id AND
    test_runs.host_id = hosts.id AND
    (test_runs.name = statistics_map.test_run_name OR statistics_map.test_run_name IS NULL) AND
    (build_configurations.name = statistics_map.build_configuration_name OR statistics_map.build_configuration_name IS NULL) AND
    (test_configurations.name = statistics_map.test_configuration_name OR statistics_map.test_configuration_name IS NULL) AND
    groups.name = statistics_map.group_name AND
    test_cases.name = statistics_map.test_case_name AND
    test_case_statistics.key = statistics_map.name
GROUP BY less_is_more
SQL
    rows = ActiveRecord::Base.connection.select_all(limits_sql)
    return nil unless rows and rows.length > 0
    rows[0]
  end

  def get_results()
    results_sql = <<SQL
SELECT
    test_runs.id AS test_run_id,
    test_runs.revision,
    test_case_statistics.value AS value,
    (CASE WHEN less_is_more = true THEN 1 ELSE 0 END) AS less_is_more,
    date_part('epoch', (select start_time from test_runs where id = '#{@test_run.id}') - test_runs.start_time) AS age
FROM
    test_cases,
    test_case_statistics,
    groups,
    test_configurations,
    build_configurations,
    test_runs,
    hosts,
    statistics_map
WHERE
    hosts.name = '#{@test_run.host.name}' AND
    test_runs.variant = '#{@test_run.variant}' AND
    test_runs.start_time <= '#{@test_run.start_time}' AND
    statistics_map.label = '#{@statistic_key}' AND
    test_case_statistics.owner_id = test_cases.id AND
    test_cases.group_id = groups.id AND
    groups.test_configuration_id = test_configurations.id AND
    test_configurations.build_configuration_id = build_configurations.id AND
    build_configurations.test_run_id = test_runs.id AND
    test_runs.host_id = hosts.id AND
    (test_runs.name = statistics_map.test_run_name OR statistics_map.test_run_name IS NULL) AND
    (build_configurations.name = statistics_map.build_configuration_name OR statistics_map.build_configuration_name IS NULL) AND
    (test_configurations.name = statistics_map.test_configuration_name OR statistics_map.test_configuration_name IS NULL) AND
    groups.name = statistics_map.group_name AND
    test_cases.name = statistics_map.test_case_name AND
    test_case_statistics.key = statistics_map.name
ORDER BY age
SQL
    ActiveRecord::Base.connection.select_all(results_sql)
  end

  def get_score(value, best, less_is_more)
    return 100.0 if (value == best) 
    return (1000.0 / (value / best)).to_i / 10.0 if less_is_more
    return (1000.0 * (value / best)).to_i / 10.0
  end
  
  def to_image
    require 'RMagick.rb'
    require 'rvg/rvg'
    limits = get_limits();
    results = get_results();
    rvg = Magick::RVG.new(240.0, 50.0).viewbox(0, 0, 240, 50) do |canvas|
      if results.length > 0 then
        oldest = limits['oldest'].to_i
        best = limits['best'].to_f
        worst = limits['worst'].to_f
        std_dev = limits['std_dev'].to_f
        less_is_more = limits['less_is_more'].to_i == 1
        worst_score = get_score(worst, best, less_is_more)
        worst_score = 95.0 if worst_score == 100.0
        font = 'Trebuchet MS'
        font_small = 'Verdana'
        x_res = 175.0
        y_res = 20.0
        y_mar = 15.0
        y_off = y_res + y_mar
        x_off = 180.0
        x_scale = x_res / oldest.to_f
        y_scale = y_res / (100.0 - worst_score)
        # most recent score
        failed = results[0]['age'].to_i > 0
        latest = results[0]['value'].to_f
        latest_score = get_score(latest, best, less_is_more)
        latest_score = 100 if latest_score == 100.0
        # print the most recent score
        if (failed) then
          canvas.text(210, 35) do |result|
            result.tspan("FAIL").styles(:text_anchor=>'middle', :font_size=>20, :font_family=>font, :fill=>'red', :font_weight => 'bold')
          end
        else
          score_color = 'black'
          score_style = 'normal'
          if (results.length >= 6) then
            avg = 0.0
            for i in (1..5)
              avg += (results[i]['value'].to_f / 5.0)
            end
            if (less_is_more) then
              if latest > (avg + 1 * std_dev) then
                score_color = 'red'
                score_style = 'bold'
              elsif latest < (avg - 1 * std_dev) then
                score_color = 'green'
                score_style = 'bold'
              end
            else
              if latest > (avg + 1 * std_dev) then
                score_color = 'green' 
                score_style = 'bold'
              elsif latest < (avg - 1 * std_dev)
                score_color = 'red' if 
                score_style = 'bold'
              end
            end
          end
          canvas.text(210, 27) do |result|
            result.tspan("#{latest_score}").styles(:text_anchor=>'middle', :font_size=>20, :font_family=>font, :font_weight => score_style, :fill=>score_color)
          end
          canvas.text(210, 39) do |result|
            result.tspan(Kernel.format("%8.8s", latest)).styles(:text_anchor=>'middle', :font_size=>8, :font_family=>font_small, :fill=>'black')
          end
        end
        min_x = nil
        min_rev = nil
        max_x = nil
        max_rev = nil
        start_x = x_off - (results[0]['age'].to_i * x_scale)
        start_y = y_off - ((latest_score - worst_score) * y_scale)
        first_x = start_x
        first_y = start_y
        results.each do |r|
          end_x = x_off - (r['age'].to_i * x_scale)
          value = r['value'].to_f
          end_y = y_off - ((get_score(value, best, less_is_more) - worst_score) * y_scale)
          if (value == best and max_x == nil) then
            max_x = end_x 
            max_rev = r['revision']
            canvas.circle(3, max_x, y_mar).styles(:stroke=>'green', :stroke_width => 1.5, :fill => 'white')
          end
          if (value == worst and not (best == worst) and min_x == nil) then
            min_x = end_x 
            min_rev = r['revision']
            canvas.circle(3, min_x, y_off).styles(:stroke=>'red', :stroke_width => 1.5, :fill => 'white')
          end
          canvas.line(start_x, start_y, end_x, end_y).styles(:stroke=>'black', :stroke_width => 1.00)
          start_x = end_x
          start_y = end_y
        end
        canvas.circle(1.5, first_x, first_y).styles(:fill=>'black')
        canvas.circle(1.5, start_x, start_y).styles(:fill=>'black')
        if min_x then
          min_x = 35.0 if min_x < 35.0
          canvas.text(min_x, y_res + 2 * y_mar - 2.0) do |result|
            result.tspan("r#{min_rev} (#{worst_score})").styles(:text_anchor=>'middle', :font_size=>8, :font_family=>font_small, :fill=>'red')
          end
        end
        if max_x then
          max_x = 20.0 if max_x < 20.0
          canvas.text(max_x, 10) do |result|
            result.tspan("r#{max_rev}").styles(:text_anchor=>'middle', :font_size=>8, :font_family=>font_small, :fill=>'green')
          end
        end
      else
        canvas.text(210, 35) do |result|
          result.tspan("FAIL").styles(:text_anchor=>'middle', :font_size=>20, :font_family=>font, :fill=>'red', :font_weight => 'bold')
        end
      end
    end
    img = rvg.draw
    img.format = 'png';
    img.to_blob
  end
end
