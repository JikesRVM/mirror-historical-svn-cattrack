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
module Explorer::FilterHelper
  def dimension_block_name(dimension)
    "#{dimension.table_name}_table"
  end

  def hide_dimension_javascript(dimension_name)
    "Element.toggle('#{dimension_name}_table'); Element.toggleClassName('#{dimension_name}_toggle','open')"
  end

  def dimension_header(dimension)
    section_header(dimension.table_name)
  end

  def section_header(name)
    "<a href=\"#\" id=\"#{name}_toggle\" class=\"toggle_visibility open\" onclick=\"#{hide_dimension_javascript(name)}; return false;\">#{name.titleize}</a>"
  end

  def dimension_footer(dimension)
    show = false
    Olap::Query::Filter::Fields.each do |f|
      if ((f.dimension == dimension) and not Olap::Query::Filter.is_empty?(@filter, f.key))
        show = true
        break
      end
    end
    show ? '' : "<script type=\"text/javascript\">#{hide_dimension_javascript(dimension.table_name)}</script>"
  end
end
