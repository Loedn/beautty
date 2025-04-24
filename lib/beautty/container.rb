# frozen_string_literal: true

require_relative 'terminal'
require_relative 'element' # Require the base class

module Beautty
  # Represents the main application drawing area (conceptually).
  # This is the root element in the UI tree.
  class Container < Element # Inherit from Element
    # No specific attributes needed beyond Element for now
    # attr_reader :height, :width <- Inherited via layout hash

    def initialize(style: {}, children: [], &definition_block)
      # Call super to set up children, style, layout etc.
      # Parent is handled automatically by Element#initialize via DSLBuilder context
      super(style: style, children: children, &definition_block)
      # Container specific setup
      update_dimensions # Set initial dimensions based on terminal
      # Color/attribute handling will be managed elsewhere (e.g., Application or Renderer)
    end

    # Fetches the current terminal dimensions via the Terminal module
    # and updates the layout hash.
    def update_dimensions
      rows = Terminal.rows
      cols = Terminal.cols
      # Update the layout hash inherited from Element (1-based coordinates)
      self.layout = { x: 1, y: 1, width: cols, height: rows }
    end

    # Provides the current height from the layout hash.
    def height
      layout[:height]
    end

    # Provides the current width from the layout hash.
    def width
      layout[:width]
    end

    # Draws the container's border using raw ANSI/Unicode output.
    def draw_border
      # Check layout validity before drawing
      return unless layout && layout[:width] > 0 && layout[:height] > 0

      # Use layout dimensions
      # Coordinates from layout are 0-based, but terminal is 1-based.
      x = layout[:x] + 1
      y = layout[:y] + 1
      h = layout[:height]
      w = layout[:width]
      return if h < 2 || w < 2 # Cannot draw border if too small

      # Top border
      Terminal.move_cursor(y, x)
      Terminal.write('┌' + ('─' * (w - 2)) + '┐')

      # Middle borders (left and right)
      (y + 1...y + h - 1).each do |row|
        Terminal.move_cursor(row, x)
        Terminal.write('│')
        Terminal.move_cursor(row, x + w - 1)
        Terminal.write('│')
      end

      # Bottom border
      Terminal.move_cursor(y + h - 1, x)
      Terminal.write('└' + ('─' * (w - 2)) + '┘')
    end

    # Handles resize events by updating dimensions.
    # The Application class coordinates clearing and triggering redraws.
    def handle_resize
      update_dimensions
      # Container doesn't need to trigger draw_border itself,
      # the Application/Renderer will handle redrawing the whole tree.
    end

    # Layout is handled by LayoutEngine
    # def calculate_layout(_parent_layout = nil)
    #   content_x = self.layout[:x] + 1
    #   content_y = self.layout[:y] + 1
    #   content_width = [self.layout[:width] - 2, 0].max
    #   content_height = [self.layout[:height] - 2, 0].max
    #   current_child_y = content_y 
    #   children.each do |child|
    #     child_parent_layout = { x: content_x, y: current_child_y, width: content_width, height: [content_height - (current_child_y - content_y), 0].max }
    #     child.calculate_layout(child_parent_layout)
    #     current_child_y += child.layout[:height]
    #   end
    # end

    # Overrides base render to draw border first, then children.
    # Container render method - now just renders children, border drawn by Application
    def render
      # Terminal.render_element handles children recursion.
      # This method only needs to draw the Container itself (border).
      draw_border
      # Call base Element render to render children
      # TODO: Or iterate explicitly? Base render might change.
      # children.each(&:render) # Handled by Terminal.render_element
      # super 
    end

    # No Curses-specific cleanup needed here anymore.
    # def close
    # end
  end
end 