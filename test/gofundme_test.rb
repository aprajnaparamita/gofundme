require "test_helper"

class GofundmeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Gofundme::VERSION
  end

  def test_that_it_has_a_delay
    assert Gofundme::GOOD_CITIZEN_DELAY >= 10
  end

  def test_it_creates_a_project
    project = Gofundme::Project.new
    refute_nil project
  end

  def test_it_parses_a_project
    project = Gofundme::Project.scrape("https://www.gofundme.com/help-me-wrap-up-my-transition")
    assert project.title == "Help Me Wrap Up My Transition"
    assert project.key == "help-me-wrap-up-my-transition"
  end

  def test_it_fetches_search_index
    search = Gofundme::Search.new("transgender")
    assert search.results == 1000
    res = search.fetch_results(1)
    assert res.length == 9
  end
end
