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
class StatisticFact < ActiveRecord::Base
  belongs_to :host, :class_name => 'HostDimension', :foreign_key => 'host_id'
  belongs_to :time, :class_name => 'TimeDimension', :foreign_key => 'time_id'
  belongs_to :revision, :class_name => 'RevisionDimension', :foreign_key => 'revision_id'
  belongs_to :test_run, :class_name => 'TestRunDimension', :foreign_key => 'test_run_id'
  belongs_to :build_target, :class_name => 'BuildTargetDimension', :foreign_key => 'build_target_id'
  belongs_to :build_configuration, :class_name => 'BuildConfigurationDimension', :foreign_key => 'build_configuration_id'
  belongs_to :test_configuration, :class_name => 'TestConfigurationDimension', :foreign_key => 'test_configuration_id'
  belongs_to :test_case, :class_name => 'TestCaseDimension', :foreign_key => 'test_case_id'
  belongs_to :source, :class_name => 'TestCase', :foreign_key => 'source_id'
  belongs_to :statistic, :class_name => 'StatisticDimension', :foreign_key => 'statistic_id'
end
