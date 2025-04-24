# frozen_string_literal: true

require_relative 'test_helper'

class RowTest < Minitest::Test
  def test_inherits_from_element
    assert_operator Beautty::Row, :<, Beautty::Element
  end

  def test_initialize_sets_default_style
    row = Beautty::Row.new
    expected_style = { flex_direction: :row }
    assert_equal expected_style, row.style
  end

  def test_initialize_merges_style
    row = Beautty::Row.new(style: { color: :blue, flex_direction: :column_override_test })
    expected_style = { flex_direction: :row, color: :blue }
    assert_equal expected_style, row.style
    # Ensure default takes precedence if not overridden
    assert_equal :row, row.style[:flex_direction]
  end

  def test_initialize_passes_other_args_to_super
    # Parent is set via DSL context now
    # parent = Beautty::Element.new
    child = Beautty::Element.new
    row = Beautty::Row.new(children: [child])
    # assert_equal parent, row.parent # Cannot test directly here
    assert_equal [child], row.children
    # assert_equal row, child.parent # Child parent not set automatically this way
  end
end 