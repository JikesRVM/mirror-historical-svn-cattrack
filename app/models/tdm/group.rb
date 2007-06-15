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
class Tdm::Group < ActiveRecord::Base
  validates_length_of :name, :in => 1..75
  validates_format_of :name, :with => /^[\-a-zA-Z_0-9]+$/
  validates_uniqueness_of :name, :scope => [:test_configuration_id]
  validates_presence_of :test_configuration_id
  validates_reference_exists :test_configuration_id, Tdm::TestConfiguration

  belongs_to :test_configuration

  has_many :test_cases, :order => 'name', :dependent => :destroy
  has_many :successes, :order => 'name', :class_name => 'TestCase', :conditions => "result = 'SUCCESS'"
  has_many :excluded, :order => 'name', :class_name => 'TestCase', :conditions => "result = 'EXCLUDED'"

  include TestCaseContainer

  def parent_node
    test_configuration
  end
end