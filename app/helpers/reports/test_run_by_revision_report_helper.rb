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
  def tests_header(name, label)
    "<a href=\"#\" id=\"#{name}_toggle\" class=\"toggle_visibility\" onclick=\"Element.toggle('#{name}'); Element.toggleClassName('#{name}_toggle','open'); return false;\">#{label}</a>"
  end

  def column_header(value,test_runs)
    test_run = test_runs.detect {|tr| tr.id.to_s == value.to_s}
    "<th class\"column\">#{test_run.label}</th>"
  end

  def cell(value)
    "<td style=\"#{cell_style(value)}\">#{value}%</td>"
  end

  COLOR_COUNT = 16
  HALF_COLOR_COUNT = COLOR_COUNT/2
  SATURATION = 256/HALF_COLOR_COUNT

  def cell_style(value)
    # Missing? green => 165, red => 255
    if value > 50
      green = SATURATION * (HALF_COLOR_COUNT * (value * 0.01)).to_i
      green = green - 1 unless green == 0
      red = (255 - green)/2
    else
      red = SATURATION * (HALF_COLOR_COUNT * (( 100 - value) * 0.01).to_i)
      red = red - 1 unless red == 0
      green = ( 255 - red )/2
    end
    "background-color: rgb(#{red},#{green},0);"
  end
end
