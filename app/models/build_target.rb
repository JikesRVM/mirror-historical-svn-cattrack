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
class BuildTarget < ActiveRecord::Base
  validates_reference_exists :test_run_id, TestRun
  validates_format_of :name, :with => /^[\-a-zA-Z_0-9]+$/
  validates_length_of :name, :in => 1..75
  validates_uniqueness_of :test_run_id
  validates_presence_of :test_run_id
  validates_reference_exists :test_run_id, TestRun

  belongs_to :test_run
  has_params :params

  def parent_node
    test_run
  end
end
