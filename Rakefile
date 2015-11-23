require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

namespace :db do

  desc "Create testing database."
  task :create do
    system("createdb --echo sql_capsule_test")
  end

  desc "Drop testing database."
  task :drop do
    system("dropdb --echo sql_capsule_test")
  end

  desc "Migrate testing database."
  task :migrate do
    require 'pg'
    db = PG.connect(dbname: 'sql_capsule_test')
    db.exec('CREATE TABLE widgets (name VARCHAR NOT NULL, price INTEGER NOT NULL, id INTEGER NOT NULL UNIQUE);')
    db.exec('CREATE TABLE orders (widget_id INTEGER NOT NULL, amount INTEGER NOT NULL, id INTEGER NOT NULL UNIQUE);')
  end

end
