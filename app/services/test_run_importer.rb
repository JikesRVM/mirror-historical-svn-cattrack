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

class ImportException < Exception
end

# Utility class for importing sets sets of
class TestRunImporter
  cattr_accessor :logger

  def self.process_incoming_test_runs(perform_mailout=false)
    results_base_dir = SystemSetting['results.dir']
    raise ImportException.new("Missing 'results.dir' system setting") unless results_base_dir
    AuditLog.log('import.started')
    logger.info("Import starting with results.dir='#{results_base_dir}'")
    incoming_dir = "#{results_base_dir}/incoming"
    processed_dir = "#{results_base_dir}/processed"
    failed_dir = "#{results_base_dir}/failed"

    Dir.glob("#{incoming_dir}/*").each do |d|
      host = File.basename(d)
      logger.info("Processing host '#{host}' in dir #{d}")
      Dir.glob("#{d}/*.xml.gz").each do |f|
        next unless File.exists?(f)
        AuditLog.log('import.file.started', f)
        logger.info("Processing file: #{f}")
        intermediate_filename = "#{f}.processing"
        temp_filename = "#{f}.tmp"
        begin
          FileUtils.mv(f, intermediate_filename)
          Zlib::GzipReader.open(intermediate_filename) do |fin|
            File.open(temp_filename, "w+") do |fout|
              fout.write(fin.read)
            end
          end
          logger.info("Unzipped file to #{temp_filename}. Size= #{File.size(temp_filename)}")

          raise ImportException.new("Unzipping #{f} produced too large a file #{File.size(temp_filename)}") unless File.size(temp_filename) < (1024 * 1024 * 30)

          test_run = TestRunBuilder.create_from(host, temp_filename)
          TestRunTransformer.build_olap_model_from(test_run)
          ReportMailer.deliver_report(Tdm::TestRun.find(test_run.id)) if perform_mailout
          logger.info("Successfully processed file: #{f}")
          AuditLog.log('import.file.success', f)
          FileUtils.mkdir_p "#{processed_dir}/#{host}"
          FileUtils.mv(intermediate_filename, "#{processed_dir}/#{host}/#{File.basename(f)}")
        rescue Object => e
          logger.info("Failed to process file: #{f} due to: #{e.message}")
          AuditLog.log('import.file.error', "Failed to process file #{f} due to #{e.message}")
          FileUtils.mkdir_p "#{failed_dir}/#{host}"
          FileUtils.mv(intermediate_filename, "#{failed_dir}/#{host}/#{File.basename(f)}")
        ensure
          FileUtils.rm_rf(temp_filename)
        end
      end
    end
    AuditLog.log('import.completed')
  end
end
