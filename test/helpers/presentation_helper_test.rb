#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
require File.dirname(__FILE__) + '/../test_helper'

class PresentationHelperTest < Test::Unit::TestCase

  class MyClass
    include PresentationHelper
  end

  def test_cell_rendering
    assert_equal('<td style="background-color: rgb(0,255,0);">100%</td>', MyClass.new.cell(100))
    assert_equal('<td style="background-color: rgb(32,191,0);">85%</td>', MyClass.new.cell(85))
    assert_equal('<td style="background-color: rgb(64,127,0);">55%</td>', MyClass.new.cell(55))
    assert_equal('<td style="background-color: rgb(0,127,0);">35%</td>', MyClass.new.cell(35))
    assert_equal('<td style="background-color: rgb(255,0,0);">0%</td>', MyClass.new.cell(0))
  end
end
