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
class Olap::Query::Measure < ActiveRecord::Base
  validates_length_of :name, :in => 1..120
  validates_uniqueness_of :name
  validates_length_of :sql, :in => 1..512
  validates_length_of :joins, :in => 0..50
  validates_inclusion_of :result_measure, :in => [true, false], :message => ActiveRecord::Errors.default_error_messages[:blank]

  has_and_belongs_to_many :presentations, :class_name => 'Olap::Query::Presentation'

  def join_dimensions
    joins.split.collect {|j| "Olap::#{j.classify}Dimension".constantize }
  end
end
