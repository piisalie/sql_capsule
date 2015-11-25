# SQLCapsule

Note: this is still under heavy construction

### Todo before first release
- [x] Refactor QueryHolder#run it's pretty terrible, maybe there's another object in there somewhere
- [x] Enforce `$1` count in SQL query should match the named arguments count when registering a query
- [x] Clean up the README
- [ ] Check/update dependencies/versions
- [ ] Describe intended usage better


SQLCapsule is the culmination of many of my thoughts surrounding ORMs and how we use Ruby to
interact with databases. The goal is to be a small and easy to understand tool to help you
talk to your database without the baggage of a full fledged ORM. This is reminiscent of the
repository pattern and done by registering and naming SQL queries for later use.

SQLCapsule aims to provide helpful errors, and to help you along your way to building
your application specific database interaction layer.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sql_capsule'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sql_capsule

## Usage

Initialize a wrapper using a PG connection object:
```ruby
user_database = SQLCapsule.wrap(pg_connection)
```

Once you have a wrapper you can register bits of SQL. The method
signature is: `query_name, raw_sql, *arguments`

```ruby
query = "SELECT * FROM users_table WHERE id = $1;"
user_database.register(:find_user, query, :id)
```

If you try and register a SQL statement using `$1` without defining an
argument name it will raise an error.

```ruby
user_database.register :find_user, "SELECT * FROM users WHERE id = $1;"
  # SQLCapsule::Query::ArgumentCountMismatchError: Argument count mismatch
  # 0 arguments provided for
  # SQL: SELECT * FROM users WHERE id = $1;
  # Args:[]
```

Likewise, if you try and register an argument without defining
its use within the SQL it will also raise an error.

```ruby
user_database.register :find_user, "SELECT * FROM users;", :id
  # SQLCapsule::Query::ArgumentCountMismatchError: Argument count mismatch
  # 1 arguments provided for
  # SQL: SELECT * FROM users;
  # Args:[:id]
```

Arguments are used in order, so if you register `:id, :name` then `$1` will
correspond with `:id` and `$2` will correspond with `:name`. SQLCapsule does
not attempt to verify your numbering. :-)

It is also possible to register a query with a block to handle the resulting rows:

```ruby
query = "SELECT * FROM users_table WHERE id = $1;", :id
user_database.register(:find_user, query, :id) { |row| row.merge('preprocessed' => true) }
user_database.run(:find_user, id: 1) => [ { 'name' => 'John', 'age' => 20, 'id' => 3, 'preprocessed' => true} ]
```

Any registered query can be called like:
```ruby
user_database.run :find_user, id: 3  # => [ { 'name' => 'John', 'age' => 20, 'id' => 3 } ]
```

Or with a block:
```ruby
user_database.run(:find_user, id: 3) { |user| user.merge('loaded' => true) }
  # => [ { 'name' => 'John', 'age' => 20, 'id' => 3, 'loaded' => true } ]
```

Run checks for required keywords when called and will throw an error if missing one:
```ruby
user_database.run :find_user
  # => SQLCapsule::QueryGroup::MissingKeywordArgumentError: Missing query argument: id
```

The result will return in the form of an array of hashes, where the keys correlate with column names:
```ruby
user_database.run :find_adult_users  # => [ { 'name' => 'John', 'age' => 20 }, { 'name' =>  'Anne', 'age' =>  23 } ]
```

### Complex Queries

One thing about SQL and relational databases is that returning tables with identical
column names is a perfectly normal and sane thing to do. SQLCapsule enforces the use
of `AS` to alias column names and will raise an error when duplicate column names result
from a query (like a join)

```ruby
query = 'SELECT * FROM widgets LEFT JOIN orders on widgets.id=orders.widget_id;'
widget_database.register :join_widgets, query
widget_database.run :join_widgets
  # SQLCapsule::Wrapper::DuplicateColumnNamesError: Error duplicate column names in resulting table: ["name", "price", "id", "widget_id", "amount", "id"]
  # This usually happens when using a `JOIN` with a `SELECT *`
  # You may need use `AS` to name your columns.
  # QUERY: SELECT * FROM widgets LEFT JOIN orders on widgets.id=orders.widget_id;
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piisalie/sql_capsule. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
