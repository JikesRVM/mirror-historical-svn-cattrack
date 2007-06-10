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
module TestCaseContainer
  def success_rate
    excluded = self.excluded.count
    total = self.test_cases.count - excluded
    postfix = (excluded > 0) ? " (#{excluded} excluded)" : ''
    "#{self.successes.count}/#{total}#{postfix}"
  end
end
