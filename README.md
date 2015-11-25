# SQLCapsule

Note: this is still under heavy construction

### Todo before first release
- [ ] Refactor QueryHolder#run it's pretty terrible, maybe there's another object in there somewhere
- [ ] Enforce `$1` count in SQL query should match the named arguments count when registering a query
- [ ] Clean up the README
- [ ] Check/update dependencies/versions
- [ ] Describe intended usage better


SQLCapsule is the culmination of many of my thoughts surrounding ORMs and how we use Ruby to
interact with databases generally. The goal is to be a small and easy to understand tool
to help you talk to your database without the baggage of a full fledged ORM. This is done
by registering and naming SQL queries for later use.


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
```
user_database = SQLCapsule.wrap(db_connection)
```

Once you have a wrapper you can register bits of SQL, the method
signature is: `query_name, raw_sql, *arguments`

```
query = "SELECT * FROM users_table WHERE id = $1;"
user_database.register(:find_user, query, :id)
```

It is also possible to register a query with a block to handle the resulting rows:

```
query = "SELECT * FROM users_table WHERE id = $1;"
user_database.register(:find_user, query, :id) { |row| User.new(row) }
```

Any registered query can be called like:
```
user_database.run :find_user, id: 3  # => [ { name: 'John', age: 20, id: 3 } ]
```

Or with a block:
```
user_database.run(:find_user, id: 3) { |user| user.merge(loaded: true) }
  # => [ { name: 'John', age: 20, id: 3, loaded: true } ]
```

Run checks for required keywords when called and will throw an error if missing one:
```
user_database.run :find_user
  # => SQLCapsule::QueryGroup::MissingKeywordArgumentError: Missing query argument: id
```

The result will return in the form of an array of hashes, where the keys correlate with column names:
```
user_database.query :find_adult_users  # => [ { name: 'John', age: 20 }, { name: 'Anne', age: 23 } ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piisalie/sql_capsule. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
