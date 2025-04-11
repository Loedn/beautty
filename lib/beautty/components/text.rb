module Beautty
  module Components
    # A component for displaying text
    class Text < Component
      attr_accessor :text
      
      def initialize(text, options = {})
        super(options)
        @text = text
      end
      
      # Override calculate_content_size to base size on text
      def calculate_content_size(available_width, available_height)
        super(available_width, available_height)
        
        # If no explicit width/height, use text dimensions
        if !@computed_style.width
          @content_width = @text.length
        end
        
        if !@computed_style.height
          @content_height = 1 # Single line of text
        end
      end
      
      # Override render to draw the text
      def render(canvas, offset_x = 0, offset_y = 0)
        super(canvas, offset_x, offset_y)
        
        style = @computed_style
        abs_x = @x + offset_x
        abs_y = @y + offset_y
        
        # Calculate text position within the component
        text_x = abs_x
        text_y = abs_y
        
        # Add padding
        text_x += style.padding[:left]
        text_y += style.padding[:top]
        
        # Add border offset if present
        if style.border
          text_x += 1
          text_y += 1
        end
        
        # Draw the text
        canvas.draw_text(text_x, text_y, @text, fg: style.fg, bg: style.bg, style: style.style)
      end
    end
  end
end 