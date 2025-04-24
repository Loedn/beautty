# frozen_string_literal: true

require_relative 'test_helper'

class DSLBuilderTest < Minitest::Test
  # Include DSL methods for direct use in tests
  include Beautty::DSLBuilder

  def setup
    # Ensure clean context before each test
    Beautty::DSLBuilder.class_variable_set(:@@current_parent, nil)
  end

  def teardown
    Beautty::DSLBuilder.class_variable_set(:@@current_parent, nil)
  end

  def test_build_sets_root_context
    root = Beautty::Element.new
    executed = false
    Beautty::DSLBuilder.build(root) do |passed_root|
      assert_equal root, Beautty::DSLBuilder.current_parent
      assert_equal root, passed_root
      executed = true
    end
    assert executed
    assert_nil Beautty::DSLBuilder.current_parent # Context should be restored
  end

  def test_within_parent_sets_context_and_evals_block
    parent = Beautty::Element.new
    new_context_element = Beautty::Element.new
    executed_in_context = false

    Beautty::DSLBuilder.class_variable_set(:@@current_parent, parent)
    
    Beautty::DSLBuilder.within_parent(new_context_element) do
      # Block executes via instance_eval, so self is new_context_element
      assert_equal new_context_element, self
      # DSLBuilder context should also be set
      assert_equal new_context_element, Beautty::DSLBuilder.current_parent
      executed_in_context = true
    end

    assert executed_in_context
    # Context should be restored to original parent
    assert_equal parent, Beautty::DSLBuilder.current_parent 
  end

  def test_dsl_methods_create_elements_and_add_to_parent
    root = Beautty::Container.new # Needs a container for structure
    result_div = nil
    result_row = nil
    result_text = nil

    Beautty::DSLBuilder.build(root) do
      result_div = div(style: { border: :double }) do
        result_row = row(style: { padding: 1 }) do
          result_text = text("Hello DSL", style: { color: :red })
        end
      end
    end

    # Check instances
    assert_instance_of Beautty::Div, result_div
    assert_instance_of Beautty::Row, result_row
    assert_instance_of Beautty::Text, result_text

    # Check parenting
    assert_equal root, result_div.parent
    assert_equal [result_div], root.children
    assert_equal result_div, result_row.parent
    assert_equal [result_row], result_div.children
    assert_equal result_row, result_text.parent
    assert_equal [result_text], result_row.children

    # Check styles
    assert_equal({ border: :double }, result_div.style)
    assert_equal({ flex_direction: :row, padding: 1 }, result_row.style)
    assert_equal({ color: :red }, result_text.style)
  end
end 