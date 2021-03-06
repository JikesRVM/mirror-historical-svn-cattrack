#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#

# Monkey patch routing so that we can use . in url options
# Specifically we use this when extracting host names from url
ActionController::Routing.send :remove_const, 'SEPARATORS'
ActionController::Routing.const_set('SEPARATORS', %w( / ; , ? ))