require 'test_helper'

class SQLCapsuleTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SQLCapsule::VERSION
  end
end
