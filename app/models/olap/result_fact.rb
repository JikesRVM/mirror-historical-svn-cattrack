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
class Olap::ResultFact < ActiveRecord::Base
  belongs_to :host, :class_name => 'Olap::HostDimension', :foreign_key => 'host_id'
  belongs_to :time, :class_name => 'Olap::TimeDimension', :foreign_key => 'time_id'
  belongs_to :revision, :class_name => 'Olap::RevisionDimension', :foreign_key => 'revision_id'
  belongs_to :test_run, :class_name => 'Olap::TestRunDimension', :foreign_key => 'test_run_id'
  belongs_to :build_target, :class_name => 'Olap::BuildTargetDimension', :foreign_key => 'build_target_id'
  belongs_to :build_configuration, :class_name => 'Olap::BuildConfigurationDimension', :foreign_key => 'build_configuration_id'
  belongs_to :test_configuration, :class_name => 'Olap::TestConfigurationDimension', :foreign_key => 'test_configuration_id'
  belongs_to :test_case, :class_name => 'Olap::TestCaseDimension', :foreign_key => 'test_case_id'
  belongs_to :source, :class_name => 'TestCase', :foreign_key => 'source_id'
  belongs_to :result, :class_name => 'Olap::ResultDimension', :foreign_key => 'result_id'
end
