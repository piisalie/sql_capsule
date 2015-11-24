require "sql_capsule/version"
require "sql_capsule/wrapper"
require "sql_capsule/query_group"

module SQLCapsule
  def self.wrap(connection)
    QueryGroup.new(Wrapper.new(connection))
  end
end
