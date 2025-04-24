# frozen_string_literal: true

require_relative 'element'

module Beautty
  # Represents a layout container that arranges its children horizontally.
  # Equivalent to setting `style: { flex_direction: :row }` on a base Element.
  class Row < Element
    # Default style for a Row.
    DEFAULT_STYLE = {
      flex_direction: :row
      # Add other Row-specific defaults if needed later (e.g., align_items?)
    }.freeze

    # Initializes a new Row element.
    # Merges provided style with default Row style.
    def initialize(style: {}, children: [], &definition_block)
      merged_style = DEFAULT_STYLE.merge(style)
      super(style: merged_style, children: children, &definition_block)
    end

    # Layout is handled by LayoutEngine
    # def calculate_layout(parent_layout)
    #   my_x = parent_layout[:x]
    #   my_y = parent_layout[:y]
    #   my_width = parent_layout[:width]
    #   my_height = 1 # Fixed height for now
    #   self.layout = { x: my_x, y: my_y, width: my_width, height: my_height }
    #   current_child_x = my_x
    #   children.each do |child|
    #     child_available_width = [my_width - (current_child_x - my_x), 0].max
    #     child_parent_layout = { x: current_child_x, y: my_y, width: child_available_width , height: my_height }
    #     child.calculate_layout(child_parent_layout)
    #     current_child_x += child.layout[:width]
    #   end
    # end

    # Row rendering (default Element rendering is fine for now)
    # def render
    #   # Could draw background color here based on style
    #   super # Render children
    # end
  end
end 