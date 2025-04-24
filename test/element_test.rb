# frozen_string_literal: true

require_relative 'test_helper'

class ElementTest < Minitest::Test
  def setup
    # Reset DSL context before each test
    Beautty::DSLBuilder.class_variable_set(:@@current_parent, nil)
  end
  
  def teardown
     Beautty::DSLBuilder.class_variable_set(:@@current_parent, nil)
  end

  def test_initialize_defaults
    element = Beautty::Element.new
    assert_nil element.parent
    assert_empty element.children
    assert_equal({}, element.style)
    assert_equal({ x: 0, y: 0, width: 0, height: 0 }, element.layout)
  end

  def test_initialize_with_arguments
    # Parent is set via DSL context, not argument
    # parent_el = Beautty::Element.new
    child_el = Beautty::Element.new # Child doesn't get parent set here
    style_hash = { color: :red }

    element = Beautty::Element.new(
      # parent: parent_el, # Removed
      style: style_hash,
      children: [child_el]
    )

    assert_nil element.parent # No DSL context active
    assert_equal [child_el], element.children
    assert_equal style_hash, element.style
    # Child's parent is NOT set automatically if passed via children array
    assert_nil child_el.parent 
  end

  def test_initialize_adds_self_to_dsl_parent
    parent_el = Beautty::Element.new
    Beautty::DSLBuilder.class_variable_set(:@@current_parent, parent_el)
    
    element = Beautty::Element.new
    
    assert_equal parent_el, element.parent
    assert_includes parent_el.children, element
  end

  def test_add_child
    parent_el = Beautty::Element.new
    child1 = Beautty::Element.new
    child2 = Beautty::Element.new

    parent_el.add_child(child1)
    assert_equal [child1], parent_el.children
    assert_equal parent_el, child1.parent

    parent_el.add_child(child2)
    assert_equal [child1, child2], parent_el.children
    assert_equal parent_el, child2.parent
  end

  def test_layout_is_mutable
    element = Beautty::Element.new
    new_layout = { x: 10, y: 5, width: 20, height: 2 }
    element.layout = new_layout
    assert_equal new_layout, element.layout
  end

  # TODO: Add tests for block initialization DSL once implemented
end 