module Beautty
  module Components
    # A simple box component that can contain other components
    class Box < Component
      attr_accessor :header_text
      
      def initialize(options = {})
        super(options)
        @header_text = options[:header]
      end
      
      # Set the header text
      # @param text [String] The header text
      # @return [void]
      def header=(text)
        @header_text = text
      end
      
      # Override render to add custom rendering for the box
      def render(canvas, offset_x = 0, offset_y = 0)
        # Get the absolute position
        abs_x = @x + offset_x
        abs_y = @y + offset_y
        
        # Draw the background if specified
        if @computed_style.bg
          canvas.draw_rect(abs_x, abs_y, @width, @height, fill: true, bg: @computed_style.bg)
        end
        
        # Draw the border if specified
        if @computed_style.border
          canvas.draw_rect(
            abs_x, abs_y, @width, @height,
            border: true,
            fg: @computed_style.fg,
            border_color: @computed_style.border_color,
            border_style: @computed_style.border_style,
            border_thickness: @computed_style.border_thickness,
            border_radius: @computed_style.border_radius
          )
        end
        
        # Render header if present
        if @header_text && !@header_text.empty? && @computed_style.border
          # Draw the header text on the top border
          # Add a space before and after the text for padding
          header = " #{@header_text} "
          
          # Ensure the header doesn't exceed the box width
          if header.length > @width - 2
            header = " #{@header_text[0...(@width - 5)]}... "
          end
          
          # Draw the header text
          canvas.draw_text(abs_x + 1, abs_y, header, fg: @computed_style.fg)
        end
        
        # Render children
        render_children(canvas, abs_x, abs_y)
      end
    end
  end
end 