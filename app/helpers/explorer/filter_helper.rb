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
    Filter::Fields.each do |f|
      show = true if ((f.dimension == dimension) and not Filter.is_empty?(@filter, f.key))
    end

    show ? '' : "<script type=\"text/javascript\">Element.hide('#{dimension_block_name(dimension)}')</script>"
  end

  def fk_select(key, options = {})
    name = options[:name] ? options[:name] : 'filter'
    object = instance_variable_get("@#{name}")

    selected = Filter.is_empty?(object, key) ? ' selected="true"' : ''
    is_multiple = (options[:multiple] and (options[:multiple] == true)) or (options[:multiple].nil? and options[:size])
    multiple = is_multiple ? " multiple=\"multiple\"" : ''
    name_suffix = is_multiple ? '[]' : ''
    size = options[:size] ? " size=\"#{options[:size]}\"" : ''
    str = "<select id=\"#{name}_#{key}\"#{multiple}#{size} name=\"#{name}[#{key}]#{name_suffix}\">"
    if options[:any]
      description = (options[:any] == true) ? 'Any' : options[:any]
      str << draw_option('', Filter.is_empty?(object, key), description)
    end
    values = options[:values] ? options[:values] : instance_variable_get("@#{key.to_s.pluralize}")
    values.each do |v|
      id = label = v
      if v.respond_to? :label
        id = v.id
        label = v.label
      elsif options[:labels]
        label = options[:labels][v]
      end
      str << draw_option(id, is_defined?(object, key, id), label)
    end
    str << '</select>'
    str
  end

  def draw_option(key, selected, label)
    selected_str = selected ? ' selected="selected"' : ''
    "<option value=\"#{key}\"#{selected_str}>#{label}</option>"
  end

  def is_defined?(object, field_symbol, value)
    v = object.send(field_symbol)
    if v.instance_of?( Array )
      return v.include?(value.to_s)
    else
      return v == value.to_s
    end
  end
end
