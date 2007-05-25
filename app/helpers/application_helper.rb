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
module ApplicationHelper
  def link_for(object, options = {})
    link_to(h(options[:label] || object.label), {:controller => "/#{object.class.table_name.singularize}", :action => 'show'}.merge(gen_link_options(object)))
  end

  def draw_breadcrumbs(object)
    bc = breadcrumbs(object).reverse
    bc.collect {|o| "#{link_for(o)}"}.join(' &gt; ')
  end

  def gen_link_options(object)
    options = {}
    breadcrumbs(object).each { |o| options["#{o.class.table_name.singularize}_id".to_sym] = o.id }
    options[:id] = object.id
    options
  end

  def breadcrumbs(object)
    options = []
    o = object.parent_node
    while o
      options << o
      o = o.parent_node
    end
    options
  end

  def attribute_error?(record, name)
    record.errors and record.errors[name]
  end

  def class_for_attribute(record, name, css)
    attribute_error?(record, name) ? "#{css} error": css
  end
end
