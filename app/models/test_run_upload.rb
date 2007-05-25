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
class TestRunUpload < ActiveForm
  validates_length_of :host, :within => 1..75
  validates_presence_of :data

  attr_accessor :host, :data

  def parent_node
    nil
  end
end
