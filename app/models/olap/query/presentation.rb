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
class Olap::Query::Presentation < ActiveRecord::Base
  validates_length_of :key, :in => 1..20
  validates_uniqueness_of :key
  validates_length_of :name, :in => 1..120
  validates_uniqueness_of :name

  has_and_belongs_to_many :measures, :class_name => 'Olap::Query::Measure'
end