# frozen_string_literal: true

require_relative 'test_helper'

class TextTest < Minitest::Test
  def test_inherits_from_element
    assert_operator Beautty::Text, :<, Beautty::Element
  end

  def test_initialize_with_content
    text_el = Beautty::Text.new("Hello")
    assert_equal "Hello", text_el.content
    # Check defaults inherited from Element
    assert_nil text_el.parent
    assert_empty text_el.children
    assert_equal({}, text_el.style)
  end

  def test_initialize_with_parent_and_style
    # Parent is set via DSL context now
    # parent = Beautty::Element.new
    style = { color: :red }
    text_el = Beautty::Text.new("World", style: style)

    assert_equal "World", text_el.content
    # assert_equal parent, text_el.parent # Cannot test directly here
    assert_equal style, text_el.style
  end
end 