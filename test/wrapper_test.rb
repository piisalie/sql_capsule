require 'test_helper'
require 'sql_capsule/wrapper'

module SQLCapsule
  class WrapperTest < MiniTest::Test
    def setup
      @db = PG.connect(dbname: 'sql_capsule_test')
      @db.type_map_for_results = PG::BasicTypeMapForResults.new @db
      @db.exec('DELETE FROM widgets;')
      @db.exec('DELETE FROM orders;')
      @db.exec("INSERT INTO widgets (name, price, id) VALUES ('hexowrench', '2999', '1');")
      @db.exec("INSERT INTO widgets (name, price, id) VALUES ('clodhopper', '350', '2');")
      @db.exec("INSERT INTO orders (widget_id, amount, id) VALUES ('1', '2999', '2');")
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
