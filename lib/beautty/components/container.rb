module Beautty
  module Components
    # A container component that uses flexbox layout
    class Container < Component
      def initialize(options = {})
        super(options)
        
        # Set default styles for container
        @style = Style.new({
          display: :flex,
          flex_direction: options[:direction] || :row,
          justify_content: options[:justify] || :flex_start,
          align_items: options[:align] || :stretch,
          padding: options[:padding] || 0,
          margin: options[:margin] || 0,
          bg: options[:bg],
          border: options[:border] || false,
          border_style: options[:border_style] || :single,
          border_radius: options[:border_radius] || false,
          # Set a reasonable default width if not specified
          width: options[:width] || '100%'
        }).merge(@style)
        
        # Add any children provided in options
        if options[:children]
          options[:children].each do |child|
            add_child(child)
          end
        end
      end
      
      # Add a child with flex options
      # @param child [Component] The child component to add
      # @param flex_grow [Integer] The flex grow factor
      # @param flex_shrink [Integer] The flex shrink factor
      # @param flex_basis [Integer, Symbol] The flex basis
      # @return [Component] The added child
      def add_flex_child(child, flex_grow: 0, flex_shrink: 1, flex_basis: :auto)
        # Set flex properties on the child's style
        child.style = child.style.with({
          flex_grow: flex_grow,
          flex_shrink: flex_shrink,
          flex_basis: flex_basis
        })
        
        # Add the child
        add_child(child)
      end
      
      # Create a row container
      # @param options [Hash] Options for the container
      # @return [Container] A new container with row direction
      def self.row(options = {})
        Container.new(options.merge(direction: :row))
      end
      
      # Create a column container
      # @param options [Hash] Options for the container
      # @return [Container] A new container with column direction
      def self.column(options = {})
        Container.new(options.merge(direction: :column))
      end
      
      # Create a centered container
      # @param options [Hash] Options for the container
      # @return [Container] A new container with centered content
      def self.centered(options = {})
        Container.new(options.merge(
          justify: :center,
          align: :center
        ))
      end
      
      # Create a container with space between items
      # @param options [Hash] Options for the container
      # @return [Container] A new container with space between items
      def self.space_between(options = {})
        Container.new(options.merge(
          justify: :space_between
        ))
      end
      
      # Create a container with space around items
      # @param options [Hash] Options for the container
      # @return [Container] A new container with space around items
      def self.space_around(options = {})
        Container.new(options.merge(
          justify: :space_around
        ))
      end
    end
  end
end 