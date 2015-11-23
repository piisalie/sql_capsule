require 'test_helper'
require 'sql_capsule/query_group'

module SQLCapsule
  class QueryGroupTest < Minitest::Test

    class TestWrapper
      def initialize(response)
        @response = response
      end

      def run query, arguments, &block
        if block_given?
          block.call(@response)
        else
          @response
        end
      end
    end

    def setup
      @user_data = { name: 'John', age: 20 }
      @name      = :find_user
      @wrapper   = TestWrapper.new(@user_data)
      @queries   = QueryGroup.new(@wrapper)
      @query_string = 'SELECT * FROM users_table WHERE id = $1;'
    end

    def test_it_registers_queries
      @queries.register @name, @query_string, :id

      assert_equal [ @name ], @queries.registered_queries
    end

    def test_it_can_run_a_query
      @queries.register @name, @query_string, :id
      result = @queries.run @name, id: 3

      assert_equal @user_data, result
    end

    def test_raises_an_error_when_missing_an_argument
      @queries.register @name, @query_string, :id

      assert_raises(QueryGroup::MissingKeywordArgumentError) { @queries.run @name }
    end

    def test_raises_an_error_if_query_is_not_registered
      assert_raises(QueryGroup::MissingQueryError) { @queries.run :not_registered }
    end

    def test_does_not_raise_error_when_given_extra_arguments
      @queries.register @name, @query_string

      assert @queries.run @name, id: 3
    end

    def test_run_accepts_a_block
      @queries.register @name, @query_string, :id

      @queries.run @name, id: 3 do |result|
        assert_equal @user_data, result
      end
    end

  end
end
