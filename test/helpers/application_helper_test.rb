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
require File.dirname(__FILE__) + '/../test_helper'

class Reports::TestRunByRevisionReportHelperTest < Test::Unit::TestCase

  class MyClass
    include ERB::Util
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ApplicationHelper

    def url_for(options)
      ActionController::Routing::Routes.reload if ActionController::Routing::Routes.empty?
      generated_path, extra_keys = ActionController::Routing::Routes.generate_extras(options, {})
      generated_path
    end
  end

  def test_revision_link
    assert_equal("<a href=\"http://svn.sourceforge.net/viewvc/jikesrvm?view=rev&amp;revision=22\">22</a>", MyClass.new.revision_link(22))
  end

  class Foo < ActiveRecord::Base
    validates_presence_of :name
    attr_accessor :name
    def initialize
    end
  end

  def test_attribute_error
    v = Foo.new
    v.valid?
    assert_equal(true, MyClass.new.attribute_error?(v, :name))
    v = Foo.new
    v.name = 'X'
    v.valid?
    assert_equal(false, MyClass.new.attribute_error?(v, :name))
  end

  def test_class_for_attribute
    v = Foo.new
    v.valid?
    assert_equal('zen error', MyClass.new.class_for_attribute(v, :name, 'zen'))
    v = Foo.new
    v.name = 'X'
    v.valid?
    assert_equal('zen', MyClass.new.class_for_attribute(Foo.new, :name, 'zen'))
  end

  def test_test_run_delete_link
    assert_equal("<li id=\"test_run_1_delete\"><a href=\"/results/skunk/core.1\" onclick=\"if (confirm('Are you sure you want to delete the core test-run?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit(); };return false;\">Delete</a><script type='text/javascript'><!--\nif(!is_admin()) Element.hide('test_run_1_delete')\n//--></script></li>\n", MyClass.new.test_run_delete_link(TestRun.find(1)))
  end

  class FakeTestRun < TestRun
    attr_accessor :label, :id, :name, :parent_node
    def self.table_name
      'test_run'
    end
    def initialize
    end
  end

  class FakeHost
    attr_accessor :label, :name, :parent_node
    def self.table_name
      'host'
    end
  end

  class FakeBuildTarget < BuildTarget
    attr_accessor :name, :parent_node
    def self.table_name
      'build_target'
    end
    def initialize
    end
  end

  def test_link_for_and_draw_breadcrumbs
    host = FakeHost.new
    host.label = 'MyHost'
    host.name = 'MyHost'
    test_run = FakeTestRun.new
    test_run.id = 1
    test_run.label = "RunLikeWind-1"
    test_run.name = "RunLikeWind"
    test_run.parent_node = host
    build_target = FakeBuildTarget.new
    build_target.name = 'ia32'
    build_target.parent_node = test_run
    assert_equal("<a href=\"/results/MyHost/RunLikeWind.1\">RunLikeWind-1</a>", MyClass.new.link_for(test_run))
    assert_equal("<a href=\"/results/MyHost/RunLikeWind.1/build_target\">ia32</a>", MyClass.new.link_for(build_target))
    assert_equal("<a href=\"/results/MyHost\">MyHost</a> &gt; <a href=\"/results/MyHost/RunLikeWind.1\">RunLikeWind-1</a>", MyClass.new.draw_breadcrumbs(test_run))
  end
end
