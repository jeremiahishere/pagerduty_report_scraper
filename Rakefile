require_relative "./lib/pagerduty_report_scraper"

task :scrap do
  PagerdutyReportScraper.scrape
end

task :generate_reports do
  PagerdutyReportScraper.generate_reports
end

task :shell do
  PagerdutyReportScraper.shell
end

# stolen from the internet (I am sure this works)
require "active_record"
require "pry"

namespace :db do

  desc "Create the database"
  task :create do
    db_config = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(db_config["database"])
    puts "Database created."
  end

  desc "Migrate the database"
  task :migrate do
    Dir.glob("db/migrate/*").sort.each do |migration_file|
      require_relative "./#{migration_file}"
      # surely there is a better way
      migration = File.basename(Dir.glob("db/migrate/*").first.tr("0-9_", ""), ".rb").camelize.constantize
      migration.new.up
    end

    Rake::Task["db:schema"].invoke
    puts "Database migrated."
  end

  desc "Drop the database"
  task :drop do
    db_config = YAML::load(File.open('config/database.yml'))
    `rm #{db_config["database"]["database"]}`
    puts "Database deleted."
  end

  desc "Reset the database"
  task :reset => [:drop, :create, :migrate]

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    require 'active_record/schema_dumper'
    filename = "db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end

end

namespace :g do
  desc "Generate migration"
  task :migration do
    name = ARGV[1] || raise("Specify name: rake g:migration your_migration")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF
class #{migration_class} < ActiveRecord::Migration[7.0]
  def self.up
  end
  def self.down
  end
end
      EOF
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end
