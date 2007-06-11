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
class Olap::Dimension < ActiveRecord::Base
  self.abstract_class = true

  class << self
    # Dimensions should have a singularized table name
    def table_name
      name = self.name.demodulize.underscore
      set_table_name(name)
      name
    end
  end
end
