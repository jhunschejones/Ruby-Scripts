Test::Unit.at_start do
  # this setup runs once at the start
  File.write(KANJI_YAML_DUMP_PATH, "added_kanji: ['形']\nskipped_kanji: []")
  Kanji.load_from_yaml_dump
  File.write(WORD_LIST_YAML_PATH, "#{WORD_LIST_KEY}: ['取り', '百万']")
end

Test::Unit.at_exit do
  # this setup runs once at the very end of the test
  File.delete(WORD_LIST_YAML_PATH)
  File.delete(KANJI_YAML_DUMP_PATH)
end

class KanjiTest < Test::Unit::TestCase

  def setup
    # this setup runs before each test
  end

  def teardown
    # this teardown runs after each test
  end

  def test_next_returns_next_character
    assert_equal "取", Kanji.next.character
  end

  def test_remaining_characters_returns_list_of_characters_not_in_database
    assert_equal ["取", "百", "万"], Kanji.remaining_characters
  end

  def test_load_from_yaml_restores_database
    kanji_before = Kanji.all
    Kanji.destroy_all
    Kanji.load_from_yaml_dump
    assert_equal 1, Kanji.count
    assert_equal kanji_before, Kanji.all
  end

  def test_add_creates_db_record_with_expected_status
    Kanji.new(character: "一").add!
    assert_equal "一", Kanji.last.character
    assert_equal Kanji::ADDED_STATUS, Kanji.last.status
    Kanji.last.destroy # cleanup
  end

  def test_skip_creates_db_record_with_expected_status
    Kanji.new(character: "一").skip!
    assert_equal "一", Kanji.last.character
    assert_equal Kanji::SKIPPED_STATUS, Kanji.last.status
    Kanji.last.destroy # cleanup
  end

  def test_duplicate_characters_are_invalid
    duplicate_kanji = Kanji.new(character: Kanji.last.character)
    refute duplicate_kanji.valid?
  end

  def test_empty_characters_are_invalid
    duplicate_kanji = Kanji.new(character: "")
    refute duplicate_kanji.valid?
  end

  def test_non_kanji_characters_are_invalid
    duplicate_kanji = Kanji.new(character: "J")
    refute duplicate_kanji.valid?
  end
end
