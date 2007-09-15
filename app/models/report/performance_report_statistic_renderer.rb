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
require 'RMagick.rb'
require 'rvg/rvg'

class Report::PerformanceReportStatisticRenderer

  def initialize(test_run, statistic_key, large)
    @test_run = test_run
    @statistic_key = statistic_key
    @large = large
  end

  def get_limits
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
    count_sql = <<SQL
SELECT
    COUNT(*) AS count
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
    (#{oldest_sql}) AS oldest,
    (#{count_sql}) AS count
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

  def get_results
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
  
  def get_x(val, step)
    step * 10.0
    n = (step * 10.0) / (0.5848932)
    Math.log10(val.to_f + n) - Math.log10(n)
  end
  
  def get_stddev(values, start_index, length, avg)
    sum_squares = 0.0
    for i in 0..length-1 do
      sum_squares += (values[i]['value'].to_f - avg)**2
    end
    (sum_squares / length)**0.5
  end
  
  def to_image
    limits = get_limits
    results = get_results
    x_size = if @large then 960.0 else 240.0 end
    y_size = if @large then 200.0 else 50.0 end
    rvg = Magick::RVG.new(x_size, y_size).viewbox(0, 0, 240, 50) do |canvas|
      if results.length > 0 then
        oldest = limits['oldest'].to_i
        best = limits['best'].to_f
        worst = limits['worst'].to_f
        count = limits['count'].to_i
        step = oldest.to_f / count.to_f
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
        x_scale = x_res / get_x(oldest.to_i, step)
        y_scale = y_res / (100.0 - worst_score)
        # most recent score
        failed = results[0]['age'].to_i > 0
        latest = results[0]['value'].to_f
        latest_score = get_score(latest, best, less_is_more)
        latest_score = 100 if latest_score == 100.0
        # print the most recent score
        moving_avg_length = 10
        moving_avg = 0.0
        std_dev = 0.0
        score_color = 'black'
        score_style = 'normal'
        if results.length > moving_avg_length then
          for i in (1..moving_avg_length)
            moving_avg += (results[i]['value'].to_f / moving_avg_length)
          end
          std_dev = get_stddev(results, 1, moving_avg_length, moving_avg)
          if not(failed) then
            if (less_is_more) then
              if latest > (moving_avg + 1 * std_dev) then
                score_color = 'red'
                score_style = 'bold'
              elsif latest < (moving_avg - 1 * std_dev) then
                score_color = 'green'
                score_style = 'bold'
              end
              if latest > (best + 1 * std_dev) then
                canvas.line(190, 30, 230, 30).styles(:stroke=>'red', :stroke_width => 1.00)
                canvas.line(190, 10, 230, 10).styles(:stroke=>'red', :stroke_width => 1.00)
              end
            else
              if latest > (moving_avg + 1 * std_dev) then
                score_color = 'green' 
                score_style = 'bold'
              elsif latest < (moving_avg - 1 * std_dev)
                score_color = 'red' if 
                score_style = 'bold'
              end
              if latest < (best - 1 * std_dev) then
                canvas.line(190, 30, 230, 30).styles(:stroke=>'red', :stroke_width => 1.00)
                canvas.line(190, 10, 230, 10).styles(:stroke=>'red', :stroke_width => 1.00)
              end
              end
          end
        end
        if (failed) then
          canvas.text(210, 35) do |result|
            result.tspan("FAIL").styles(:text_anchor=>'middle', :font_size=>20, :font_family=>font, :fill=>'red', :font_weight => 'bold')
          end
        else
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
        start_x = x_off - get_x(results[0]['age'].to_i, step) * x_scale
        start_y = y_off - ((latest_score - worst_score) * y_scale)
        first_x = start_x
        first_y = start_y
        if results.length > moving_avg_length then
          last_avg_high = y_off - (get_score(moving_avg + std_dev, best, less_is_more) - worst_score) * y_scale
          last_avg_mid = y_off - (get_score(moving_avg, best, less_is_more) - worst_score) * y_scale
          last_avg_low = y_off - (get_score(moving_avg - std_dev, best, less_is_more) - worst_score) * y_scale
        end
        last_drawn = 100000.0
        average_index = moving_avg_length
        results.each do |r|
          end_x = x_off - get_x(r['age'].to_i, step) * x_scale
          value = r['value'].to_f
          score = get_score(value, best, less_is_more)
          end_y = y_off - (score - worst_score) * y_scale
          revision = r['revision']
          if average_index > moving_avg_length and average_index < results.length then
            std_dev = get_stddev(results, average_index - moving_avg_length - 1, moving_avg_length, moving_avg)
            avg_high = y_off - (get_score(moving_avg + std_dev, best, less_is_more) - worst_score) * y_scale
            avg_mid = y_off - (get_score(moving_avg, best, less_is_more) - worst_score) * y_scale
            avg_low = y_off - (get_score(moving_avg - std_dev, best, less_is_more) - worst_score) * y_scale
            canvas.polygon(start_x, last_avg_high, end_x, avg_high, end_x, avg_low, start_x, last_avg_low).styles(:fill=>'#e0e0ff', :opacity => 1.0, :stroke => 'none')
            canvas.line(start_x, last_avg_mid, end_x, avg_mid).styles(:stroke=>'#c0c0ff', :stroke_width => 1)
            last_avg_high = avg_high
            last_avg_mid = avg_mid
            last_avg_low = avg_low
            last_avg = moving_avg
            moving_avg -= results[average_index - moving_avg_length]['value'].to_f / moving_avg_length.to_f
            moving_avg += results[average_index]['value'].to_f / moving_avg_length.to_f
          end
          average_index += 1
          if (value == best and max_x == nil) then
            max_x = end_x 
            max_rev = revision
          end
          if (value == worst and not (best == worst) and min_x == nil) then
            min_x = end_x 
            min_rev = revision
          end
          canvas.line(start_x, start_y, end_x, end_y).styles(:stroke=>'black', :stroke_width => 1.00, :stroke_linecap => 'round')
          if @large and (end_x + 3.0) < last_drawn then
            last_drawn = end_x
            canvas.text(end_x + 1, 10).rotate(270) do |result|
              result.tspan("r#{revision}").styles(:text_anchor=>'start', :font_size=>2.00, :font_family=>font_small)
            end
            canvas.text(end_x + 1, y_res + 2 * y_mar - 5.0).rotate(270) do |result|
              result.tspan("#{score}").styles(:text_anchor=>'start', :font_size=>2.00, :font_family=>font_small)
            end
          end
          start_x = end_x
          start_y = end_y
        end
        canvas.circle(1.5, first_x, first_y).styles(:fill=>'black')
        canvas.circle(1.5, start_x, start_y).styles(:fill=>'black')
        if min_x then
          canvas.circle(3, min_x, y_off).styles(:stroke=>'red', :stroke_width => 1.5, :fill => 'transparent', :stroke_linecap => 'round')
          if not @large then
            min_x = 35.0 if min_x < 35.0
            canvas.text(min_x, y_res + 2 * y_mar - 2.0) do |result|
              result.tspan("r#{min_rev} (#{worst_score})").styles(:text_anchor=>'middle', :font_size=>8, :font_family=>font_small, :fill=>'red')
            end
          end
        end
        if max_x then
          canvas.circle(3, max_x, y_mar).styles(:stroke=>'green', :stroke_width => 1.5, :fill => 'transparent', :stroke_linecap => 'round')
          if not @large then
            max_x = 20.0 if max_x < 20.0
            canvas.text(max_x, 10) do |result|
              result.tspan("r#{max_rev}").styles(:text_anchor=>'middle', :font_size=>8, :font_family=>font_small, :fill=>'green')
            end
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
