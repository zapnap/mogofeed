require 'environment'
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
  task :migrate do
    DataMapper.auto_migrate!
  end

  desc 'Auto-upgrade the database (preserves data)'
  task :upgrade do
    DataMapper.auto_upgrade!
  end
end

namespace :feeds do
  desc 'Update the local feed cache'
  task :update do
    Feed.all.each do |feed|
      count = feed.update_from_remote
      puts "#{feed.title} :: #{count} new entries retrieved"
    end
  end

  desc 'Add a feed to the system (URL=http://blog.zerosum.org/feed/atom.xml)'
  task :add do
    raise "ERROR: You must specify a valid feed URL!" unless feed_url = ENV['URL']
    Feed.create(:feed_url => feed_url)
  end
end

namespace :gems do
  desc 'Install required gems'
  task :install do
    required_gems = %w{ sinatra dm-core dm-aggregates dm-validations dm-is-paginated merb-pagination
                        haml pauldix-feedzirra thoughtbot-factory_girl rspec rspec_hpricot_matchers }
    required_gems.each { |required_gem| system "sudo gem install #{required_gem}" }
  end
end
