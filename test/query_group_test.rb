require 'test_helper'
require 'sql_capsule/query_group'

module SQLCapsule
  class QueryGroupTest < Minitest::Test

    def setup
      @db = PG.connect(dbname: 'sql_capsule_test')
      @name      = :find_widget
      @wrapper   = Wrapper.new(@db)
      @queries   = QueryGroup.new(@wrapper)
      @query_string = 'SELECT * FROM widgets WHERE id = $1;'
    end

    def test_it_registers_queries
      @queries.register @name, @query_string, :id

      assert_equal [ @name ], @queries.registered_queries
    end

    def test_it_registers_a_query_with_a_block
      @queries.register(@name, @query_string, :id) { |result| result.map { |widget| widget["name"]}}
      result = @queries.run @name, id: 1
      assert_equal ["hexowrench"], result
    end

    def test_it_can_run_a_query
      @queries.register @name, @query_string, :id
      result = @queries.run @name, id: 1

      assert_equal [{"name"=>"hexowrench", "price"=>"2999", "id"=>"1"}], result
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

      assert @queries.run @name, id: 1
    end

    def test_a_query_can_be_called_with_a_block
      @queries.register @name, @query_string

      @queries.run(@name, id: 1) do |result|
        assert_equal "hexowrench", result["name"]
      end
    end

  end
end
