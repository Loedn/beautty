# frozen_string_literal: true

require_relative 'test_helper'

class DivTest < Minitest::Test
  def test_inherits_from_element
    assert_operator Beautty::Div, :<, Beautty::Element
  end

  def test_initialize_defaults
    div = Beautty::Div.new
    assert_nil div.parent
    assert_empty div.children
    assert_equal({}, div.style)
  end

  def test_initialize_with_style_and_children
    # Parent is set via DSL context now
    # parent = Beautty::Element.new
    child = Beautty::Element.new
    style = { border: :single, header: "Test" }
    div = Beautty::Div.new(style: style, children: [child])

    # assert_equal parent, div.parent # Cannot test directly here
    assert_equal [child], div.children
    assert_equal style, div.style
    # assert_equal div, child.parent # Child parent not set automatically this way
  end

  # TODO: Add more tests for layout and render behavior
  # These will likely require mocking Terminal calls extensively
end 