require 'test_helper'
require 'sql_capsule/wrapper'

module SQLCapsule
  class WrapperTest < MiniTest::Test
    def setup
      @db = setup_test_database
    end

    def test_can_run_a_query
      wrapper  = Wrapper.new(@db)
      result   = wrapper.run 'SELECT * FROM widgets WHERE name = $1;', [ 'hexowrench' ]
      wrenches = [{ 'name' => 'hexowrench', 'price' => 2999, 'id' => 1 }]
      assert_equal wrenches, result
    end

    def test_it_raises_an_error_when_multiple_result_columns_share_a_name
      wrapper = Wrapper.new(@db)
      query   = 'SELECT * FROM widgets LEFT JOIN orders on widgets.id=orders.widget_id;'
      assert_raises(Wrapper::DuplicateColumnNamesError){ wrapper.run query }
    end

  end

end
