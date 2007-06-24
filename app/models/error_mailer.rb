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
class ErrorMailer < ActionMailer::Base
  def error(exception)
    @subject    = 'CatTrack Error'
    @body       = {}
    @body["exception"] = exception
    @recipients = SystemSetting['mail.on.error']
    @from       = SystemSetting['mail.from']
    @sent_on    = Time.now
    @headers    = {}
    content_type("text/html")
  end
end
