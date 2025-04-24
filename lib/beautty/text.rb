# frozen_string_literal: true

require_relative 'element'

module Beautty
  # Represents a basic text element.
  class Text < Element
    attr_reader :content

    # Initializes a new Text element.
    # @param content [String] The text content.
    # @param style [Hash] Style options.
    def initialize(content, style: {})
      @content = content
      # Provide empty block to super to avoid DSL issues for simple elements
      # Parent is now set automatically via super() + DSLBuilder context
      super(style: style) {}
    end

    # Layout is handled by LayoutEngine
    # def calculate_layout(parent_layout)
    #   my_width = @content.length
    #   my_height = 1 # Single line text for now
    #   self.layout = { x: parent_layout[:x], y: parent_layout[:y], width: my_width, height: my_height }
    # end

    # Renders the text content at the calculated position.
    def render
      return unless layout && layout[:width] > 0 && layout[:height] > 0

      # TODO: Apply styles (colors)
      # Clip content to fit within the layout width
      visible_content = content.slice(0, layout[:width])
      
      # Position cursor at the start of the layout area
      Terminal.move_cursor(layout[:y] + 1, layout[:x] + 1) # +1 for 1-based terminal coords
      Terminal.write(visible_content)
      # Text elements don't have children to render.
    end

    # Basic inspection
    def inspect
      "#<#{self.class.name} content=\"#{@content}\">"
    end
  end
end 