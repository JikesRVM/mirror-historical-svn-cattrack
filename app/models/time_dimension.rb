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
class TimeDimension < ActiveRecord::Base
  validates_inclusion_of :year, :in => 2000..2100
  validates_inclusion_of :month, :in => 1..12
  validates_inclusion_of :week, :in => 1..52
  validates_inclusion_of :day_of_year, :in => 1..365
  validates_inclusion_of :day_of_month, :in => 1..31
  validates_inclusion_of :day_of_week, :in => 1..7
end
