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
class DimensionField
  attr_reader :id, :label, :dimension

  def initialize(field)
    @id = "#{field.dimension.table_name}.#{field.name}"
    @label = "#{field.dimension_name.tableize.singularize.humanize}/#{field.name.to_s.humanize}"
    @dimension = field.dimension
  end
end
