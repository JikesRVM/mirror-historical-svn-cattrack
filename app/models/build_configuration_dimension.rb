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
class BuildConfigurationDimension < ActiveRecord::Base
  validates_inclusion_of :bootimage_compiler, :in => %w( base opt )
  validates_inclusion_of :runtime_compiler, :in => %w( base opt )
  validates_inclusion_of :assertion_level, :in => %w( none normal extreme )
  validates_inclusion_of :bootimage_class_inclusion_policy, :in => %w( minimal complete )
end
