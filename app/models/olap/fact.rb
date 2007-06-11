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
class Olap::Fact < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def dimension(name)
      type = "Olap::#{name.to_s.camelize}Dimension".constantize
      validates_presence_of type.relation_name
      validates_reference_exists type.relation_name, type

      belongs_to name, :class_name => type.name, :foreign_key => type.relation_name
    end
  end
end
