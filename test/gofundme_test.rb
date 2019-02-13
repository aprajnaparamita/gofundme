require "test_helper"

class GofundmeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Gofundme::VERSION
  end

  def test_it_creates_an_object
    project = Gofundme::Project.new(10)
    refute_nil project
  end
end
