require 'spec/rake/spectask'

task :default => :test
task :test => :spec

if !defined?(Spec)
  puts "spec targets require RSpec"
else
  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts = ['-cfs']
  end
end

namespace :db do
  desc 'Auto-migrate the database (destroys data)'
  task :migrate => :environment do
    DataMapper.auto_migrate!
  end

  desc 'Auto-upgrade the database (preserves data)'
  task :upgrade => :environment  do
    DataMapper.auto_upgrade!
  end
end

namespace :feeds do
  desc 'Update the local feed cache'
  task :update => :environment do
    Feed.all.each do |feed|
      count = feed.update_from_remote
      puts "#{feed.title} :: #{count} new entries retrieved"
    end
  end

  desc 'Add a feed to the system (URL=http://blog.zerosum.org/feed/atom.xml)'
  task :add => :environment do
    raise "ERROR: You must specify a valid feed URL!" unless feed_url = ENV['URL']
    Feed.create(:feed_url => feed_url)
  end
end

namespace :sphinx do
  desc 'configure the search Sphinx engine'
  task :configure => :environment do
    # create tmp and db directories
    require 'fileutils'
    basedir = File.dirname(__FILE__)
    ["tmp/sphinx/log", "db/sphinx"].each do |dir|
      FileUtils.mkdir_p "#{basedir}/#{dir}" unless File.exists? "#{basedir}/#{dir}"
    end

    # copy default config
    FileUtils.cp "#{basedir}/sphinx.conf.example", "#{basedir}/sphinx.conf" unless File.exists? "#{basedir}/sphinx.conf"
  end

  namespace :search do
    desc 'start the Sphinx search daemon'
    task :start => :configure do
      cmd = "searchd --config sphinx.conf"
      cmd << "> /dev/null" unless Rake.application.options.trace
      system(cmd)
    end

    desc 'stop the Sphinx search daemon'
    task :stop => :configure do
      cmd = "searchd --stop"
      system(cmd)
    end
  end

  desc 'run the search indexer'
  task :reindex => :configure do
    cmd = "indexer --all --config sphinx.conf"
    cmd << " --rotate" if File.exists? "#{File.dirname(__FILE__)}/tmp/sphinx/log/searchd.pid"
    system(cmd)
  end
end

namespace :gems do
  desc 'Install required gems'
  task :install do
    required_gems = %w{ sinatra dm-core dm-aggregates dm-validations dm-timestamps dm-is-paginated 
                        dm-is-searchable shanna-dm-sphinx-adapter merb-pagination haml
                        pauldix-feedzirra thoughtbot-factory_girl rspec rspec_hpricot_matchers }
    required_gems.each { |required_gem| system "sudo gem install #{required_gem}" }
  end
end

desc 'Initialize the environment'
task :environment do
  require 'environment'
end
