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

# Mail settings
ActionMailer::Base.server_settings = {
:address => "domain.of.smtp.host.net",
:port => 25,
:domain => "domain.of.sender.net",
:authentication => :login,
:user_name => "bob",
:password => "secret",
}

ActionMailer::Base.default_charset = "utf-8"

# Uncomment if not hosted at top level
# ActionController::AbstractRequest.relative_url_root = "/cattrack"