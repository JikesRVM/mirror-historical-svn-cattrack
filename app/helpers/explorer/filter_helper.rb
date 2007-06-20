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
  def dimension_name(dimension)
    dimension.table_name
  end

  def dimension_block_name(dimension)
    "#{dimension_name(dimension)}_table"
  end

  def dimension_header(dimension)
    name = dimension_name(dimension)
    "<a href=\"#\" id=\"#{name}_toggle\" class=\"toggle_visibility\" onclick=\"Element.toggle('#{dimension_block_name(dimension)}'); Element.toggleClassName('#{name}_toggle','open'); return false;\">#{name.humanize}</a>"
  end

  def dimension_footer(dimension)
    show = false
    Olap::Query::Filter::Fields.each do |f|
      show = true if ((f.dimension == dimension) and not Olap::Query::Filter.is_empty?(@filter, f.key))
    end

    show ? '' : "<script type=\"text/javascript\">Element.hide('#{dimension_block_name(dimension)}')</script>"
  end

  def fk_select(key, options = {})
    name = options[:name] ? options[:name] : 'filter'
    object = instance_variable_get("@#{name}")
    values = options[:values] ? options[:values] : instance_variable_get("@#{key.to_s.pluralize}")
    "<select multiple=\"multiple\" size=\"4\" name=\"#{name}[#{key}][]\">#{options_for_select(values, object.send(key))}</select>"
  end
end
