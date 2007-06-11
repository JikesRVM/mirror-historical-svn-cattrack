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
class Olap::BuildTargetDimension < Olap::Dimension
  validates_length_of :name, :in => 1..75
  validates_length_of :arch, :in => 1..10
  validates_inclusion_of :address_size, :in => [32, 64]
  validates_length_of :operating_system, :in => 1..50
end
