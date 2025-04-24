# frozen_string_literal: true

require_relative 'element'
require_relative 'terminal' # Needed for drawing border/header

module Beautty
  # Represents a generic container element (like HTML <div>).
  # Used for grouping other elements, applying borders, and displaying headers.
  class Div < Element

    # Initializes a new Div element.
    # Accepts standard Element options (parent, style, children, block).
    def initialize(style: {}, children: [], &definition_block)
      # TODO: Consider default styles for Div (e.g., flex_direction?)
      super(style: style, children: children, &definition_block)
    end

    # Renders the Div, including optional border and header, then its children.
    def render
      # Terminal.render_element handles children recursion.
      # This method only needs to draw the Div itself (border/header).
      draw_border_and_header
      # render_children # Handled by Terminal.render_element
    end

    # Layout is handled by LayoutEngine
    # def calculate_layout(parent_layout)
    #   my_x = parent_layout[:x]
    #   my_y = parent_layout[:y]
    #   my_width = parent_layout[:width]
    #   calculated_height = 0
    #   border_size = style[:border] && style[:border] != :none ? 1 : 0
    #   content_x = my_x + border_size
    #   content_y = my_y + border_size
    #   content_width = [my_width - (border_size * 2), 0].max
    #   available_content_height = parent_layout[:height] - (border_size * 2)
    #   current_child_y = content_y
    #   children.each do |child|
    #     child_available_height = [available_content_height - (current_child_y - content_y), 0].max
    #     child_parent_layout = { x: content_x, y: current_child_y, width: content_width, height: child_available_height }
    #     child.calculate_layout(child_parent_layout)
    #     current_child_y += child.layout[:height]
    #   end
    #   content_height = current_child_y - content_y
    #   my_height = content_height + (border_size * 2)
    #   self.layout = { x: my_x, y: my_y, width: my_width, height: my_height }
    # end

    private

    def draw_border_and_header
      # Check layout validity before drawing
      return unless layout && layout[:width] > 0 && layout[:height] > 0
      return if style[:border] == :none || style[:border].nil?

      # Use 1-based coordinates for terminal
      x = layout[:x] + 1
      y = layout[:y] + 1
      h = layout[:height]
      w = layout[:width]
      return if h < 2 || w < 2 # Cannot draw border if too small

      # TODO: Use different border chars based on style[:border] (:single, :double)
      v_char = '│'
      h_char = '─'
      tl_char = '┌'
      tr_char = '┐'
      bl_char = '└'
      br_char = '┘'

      # Draw border
      Terminal.move_cursor(y, x)
      Terminal.write(tl_char + (h_char * (w - 2)) + tr_char)
      (y + 1...y + h - 1).each do |row|
        Terminal.move_cursor(row, x)
        Terminal.write(v_char)
        Terminal.move_cursor(row, x + w - 1)
        Terminal.write(v_char)
      end
      Terminal.move_cursor(y + h - 1, x)
      Terminal.write(bl_char + (h_char * (w - 2)) + br_char)

      # Draw Header/Shortcut text on top border
      if style[:header]
        header_text = style[:header].to_s
        max_header_len = w - 4 # Space for corners/padding
        header_text = header_text.slice(0, max_header_len) if header_text.length > max_header_len
        Terminal.move_cursor(y, x + 2)
        Terminal.write(header_text)
      end
    end
    
    # No longer needed, handled by Terminal.render_element
    # def render_children
    #     children.each(&:render)
    # end

  end
end 