#!/usr/bin/env ruby
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
src_dir = '/home/peterd/results'
dest_dir = '/home/peterd/result_processed'
unprocessed_dir = '/home/peterd/result_unprocessed'

FileUtils.mkdir_p dest_dir

user = User.find_by_username('upload_tool')

Dir.glob("#{src_dir}/*").each do |d|
  host = File.basename(d)
  puts "Processing host #{host} in dir #{d}\n"
  Dir.glob("#{d}/*.xml.gz").each do |f|
    puts "Processing file = #{f}\n"
    STDOUT.flush
    begin
      @test_run = TestRunBuilder.create_from(host, f, user, Time.now)
      TestRunTransformer.build_olap_model_from(@test_run)
      puts "Successfully processed file #{f}\n"
      FileUtils.mkdir_p "#{dest_dir}/#{host}"
      FileUtils.mv(f, "#{dest_dir}/#{host}/#{File.basename(f)}")
    rescue BuilderException => e
      puts "Invalid file #{f} #{e.message}\n"
      FileUtils.mkdir_p "#{unprocessed_dir}/#{host}"
      FileUtils.mv(f, "#{unprocessed_dir}/#{host}/#{File.basename(f)}")
    end
  end
end

