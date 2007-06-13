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
    label = options[:label] || object.label
    action = options[:action] || 'show'
    controller = options[:controller] || "/results/#{object.class.table_name.singularize}"
    link_to(h(label), {:controller => controller, :action => action}.merge(gen_link_options(object)))
  end

  def gen_link_options(object)
    options = {}
    breadcrumbs(object).each do |o|
      if o.is_a? TestRun
        options["#{o.class.table_name.singularize}_id".to_sym] = o.id
      end
      if not o.is_a? BuildTarget
        options["#{o.class.table_name.singularize}_name".to_sym] = o.name
      end
    end
    options
  end

  def draw_breadcrumbs(object)
    bc = breadcrumbs(object).reverse
    bc.collect {|o| "#{link_for(o)}"}.join(' &gt; ')
  end

  def gen_link_options_old(object)
    options = {}
    breadcrumbs(object).each { |o| options["#{o.class.table_name.singularize}_id".to_sym] = o.id }
    options[:id] = object.id
    options
  end

  def breadcrumbs(object)
    options = []
    o = object
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

  def test_run_delete_link(test_run)
    params = {:controller => '/results/test_run', :action => 'destroy', :host_name => test_run.host.name, :test_run_name => test_run.name, :test_run_id => test_run.id}
    options = {:method => :delete, :confirm => "Are you sure you want to delete the #{test_run.name} test-run?"}
    link = link_to('Delete', params, options)
    s = <<EOS
<li id="test_run_#{test_run.id}_delete">#{link}<script type='text/javascript'><!--
if(!is_admin()) Element.hide('test_run_#{test_run.id}_delete')
//--></script></li>
EOS
  end

  def revision_link(revision)
    "<a href=\"#{h(SystemSetting['scm.url'].gsub(/@@revision@@/,revision.to_s))}\">#{h(revision)}</a>"
  end
end
