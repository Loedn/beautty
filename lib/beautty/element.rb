# frozen_string_literal: true

module Beautty
  # Base class for all UI components in the element tree.
  class Element
    # @return [Element, nil] The parent element in the tree.
    attr_accessor :parent
    # @return [Array<Element>] The child elements.
    attr_reader :children
    # @return [Hash] Style properties (layout, appearance).
    attr_reader :style
    # @return [Hash] Calculated layout (:x, :y, :width, :height).
    attr_accessor :layout

    # Initializes a new Element.
    # @param style [Hash] Style options.
    # @param children [Array<Element>] Initial children (usually empty when using DSL).
    # @param definition_block [Proc] Block executed in the element's context for DSL.
    def initialize(style: {}, children: [], &definition_block)
      @parent = DSLBuilder.current_parent # Set parent from DSL context
      @style = style
      @children = children
      @layout = { x: 0, y: 0, width: 0, height: 0 } # Default layout

      # Let the DSLBuilder handle block execution and context
      # if definition_block
      #   DSLBuilder.within_parent(self, &definition_block)
      # end

      # Ensure children added directly also have their parent set
      # This might be redundant if only using DSL
      @children.each { |child| child.parent = self }
      
      # Add self to parent if created within DSL context
      @parent&.add_child(self) unless @parent.nil? || @parent.children.include?(self)
    end

    # Adds a child element to this element.
    # @param child [Element] The child element to add.
    # @return [Element] The added child element.
    def add_child(child)
      child.parent = self
      @children << child
      # TODO: Mark self/tree as needing layout/render?
      child
    end

    # Placeholder methods for layout and rendering coordination
    # Layout calculation is now handled by LayoutEngine
    # def calculate_layout(parent_layout = { x: 0, y: 0, width: 0, height: 0 })
    #   self.layout = { x: parent_layout[:x], y: parent_layout[:y], width: 0, height: 0 }
    #   children.each { |child| child.calculate_layout(self.layout) }
    # end

    # Default render (draws children)
    def render
      # TODO: Apply styles (colors, etc.) for the element itself if needed?
      children.each(&:render)
    end

    # Basic inspection
    def inspect
      "#<#{self.class.name} children=#{@children.size}>"
    end
  end
end 