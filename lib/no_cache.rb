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
ActionController::Base.class_eval do

  protected

  def self.force_no_cache
    before_filter :force_no_cache_filter_method
  end

  #
  # Perform the voodoo required to force user agent to not cache.
  #
  def force_no_cache_filter_method
    # set modify date to current timestamp
    response.headers["Last-Modified"] = CGI::rfc1123_date(Time.now)

    # set expiry to back in the past (makes us a bad candidate for caching)
    response.headers["Expires"] = 0

    # HTTP 1.0 (disable caching)
    response.headers["Pragma"] = "no-cache"

    # HTTP 1.1 (disable caching of any kind)
    # HTTP 1.1 'pre-check=0, post-check=0' => (Internet Explorer should always check)
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate, pre-check=0, post-check=0"
  end
end
