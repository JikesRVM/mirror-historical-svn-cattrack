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
module ActiveRecord
  class Base
    def self.preload_active_records
      ::ActiveRecordClassNames.collect {|t| t.constantize }
    end

    def self.label
      self.name.humanize
    end

    def label
      if self.respond_to?(:name)
        self.name
      else
        self.to_s
      end
    end
  end
end