$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sql_capsule'

require 'minitest/autorun'

def setup_test_database
  @db = PG.connect(dbname: 'sql_capsule_test')
  @db.type_map_for_results = PG::BasicTypeMapForResults.new @db
  @db.exec('DELETE FROM widgets;')
  @db.exec('DELETE FROM orders;')
  @db.exec("INSERT INTO widgets (name, price, id) VALUES ('hexowrench', '2999', '1');")
  @db.exec("INSERT INTO widgets (name, price, id) VALUES ('clodhopper', '350', '2');")
  @db.exec("INSERT INTO orders (widget_id, amount, id) VALUES ('1', '2999', '2');")
  @db
end
