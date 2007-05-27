desc "Cleanup Backup files"
task 'tmp:cache:clear' => :environment do
  FileUtils.rm_rf(Dir["#{RAILS_ROOT}/public/host"])
end

Rake::Task['tmp:clear'].enhance(['tmp:cache:clear'])
