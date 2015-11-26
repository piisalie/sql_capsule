require 'test_helper'

require 'sql_capsule/query'

module SQLCapsule
  class QueryTest < Minitest::Test

    def setup
      @sql = "SELECT * FROM widgets;"
    end

    def test_it_holds_some_sql
      query = Query.new(@sql)
      assert_equal @sql, query.to_sql
    end

    def test_supports_named_arguments
      sql_with_argument = "SELECT * FROM widgets WHERE id = $1;"
      query_with_args = Query.new(sql_with_argument, :id)
      assert_equal [:id], query_with_args.args
    end

    def test_it_takes_an_optional_block
      block = Proc.new { |row| row }
      query = Query.new(@sql, &block)
      assert_equal block, query.pre_processor
    end

    def test_it_adds_the_semicolon_for_you
      sql = "SELECT * FROM widgets"
      query = Query.new(sql)
      assert_equal sql + ";", query.to_sql
    end

    def test_raises_error_if_arg_count_isnt_met
      sql = "SELECT * FROM widgets WHERE id = $1"

      assert_raises(Query::ArgumentCountMismatchError) { Query.new(sql) }
      assert_raises(Query::ArgumentCountMismatchError) { Query.new(sql, :id, :lol) }
      assert Query.new(sql, :id)
    end

    def test_retrieves_only_the_required_arguments
      sql        = "SELECT * FROM widgets WHERE id = $1"
      query      = Query.new(sql, :id)
      given      = { id: 3, sku: 30494 }

      assert_equal([ 3 ], query.filter_args(given))
    end

    def test_always_returns_arguments_in_coorect_order
      sql        = "SELECT * FROM widgets WHERE name LIKE $1 LIMIT $1"
      query      = Query.new(sql, :name, :limit)
      given      = { limit: 2, name: '%lo%' }

      assert_equal [ '%lo%', 2 ], query.filter_args(given)
    end
  end
end
