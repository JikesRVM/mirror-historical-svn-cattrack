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
class Olap::ResultFact < Olap::Fact
  dimension :host
  dimension :time
  dimension :revision
  dimension :test_run
  dimension :build_target
  dimension :build_configuration
  dimension :test_configuration
  dimension :test_case
  dimension :result

  validates_reference_exists :source_id, Tdm::TestCase
  belongs_to :source, :class_name => 'Tdm::TestCase', :foreign_key => 'source_id'
end
