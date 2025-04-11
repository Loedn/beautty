module Beautty
  # Represents a drawing canvas for the terminal
  class Canvas
    attr_reader :width, :height, :buffer
    
    def initialize(width, height)
      @width = width
      @height = height
      @terminal = Terminal.new
      @current_buffer = create_buffer
      @back_buffer = create_buffer
      clear
    end
    
    # Resize the canvas
    # @param width [Integer] The new width
    # @param height [Integer] The new height
    # @return [void]
    def resize(width, height)
      @width = width
      @height = height
      
      # Create new buffers with the new size
      new_current = create_buffer
      new_back = create_buffer
      
      # Copy as much of the old buffer as will fit
      @height.times do |y|
        next if y >= @current_buffer.length
        
        @width.times do |x|
          next if x >= @current_buffer[y].length
          
          new_current[y][x] = @current_buffer[y][x]
          new_back[y][x] = @back_buffer[y][x]
        end
      end
      
      @current_buffer = new_current
      @back_buffer = new_back
    end
    
    # Clear the canvas
    # @return [void]
    def clear
      @height.times do |y|
        @width.times do |x|
          @back_buffer[y][x] = { char: ' ', fg: nil, bg: nil, style: nil }
        end
      end
    end
    
    # Draw text at a specific position
    # @param x [Integer] The x coordinate (column)
    # @param y [Integer] The y coordinate (row)
    # @param text [String] The text to draw
    # @param options [Hash] Options for drawing the text
    # @option options [Symbol] :fg Foreground color
    # @option options [Symbol] :bg Background color
    # @option options [Symbol] :style Text style (bold, italic, etc.)
    # @return [void]
    def draw_text(x, y, text, options = {})
      return if y < 0 || y >= @height
      
      text.each_char.with_index do |char, i|
        pos_x = x + i
        next if pos_x < 0 || pos_x >= @width
        
        @back_buffer[y][pos_x] = {
          char: char,
          fg: options[:fg],
          bg: options[:bg],
          style: options[:style]
        }
      end
    end
    
    # Draw a horizontal line
    # @param x [Integer] The starting x coordinate
    # @param y [Integer] The y coordinate
    # @param length [Integer] The length of the line
    # @param options [Hash] Options for drawing the line
    # @option options [String] :char The character to use for the line
    # @option options [Symbol] :fg Foreground color
    # @option options [Symbol] :bg Background color
    # @return [void]
    def draw_hline(x, y, length, options = {})
      char = options[:char] || '─'
      
      length.times do |i|
        pos_x = x + i
        next if pos_x < 0 || pos_x >= @width || y < 0 || y >= @height
        
        @back_buffer[y][pos_x] = {
          char: char,
          fg: options[:fg],
          bg: options[:bg],
          style: options[:style]
        }
      end
    end
    
    # Draw a vertical line
    # @param x [Integer] The x coordinate
    # @param y [Integer] The starting y coordinate
    # @param length [Integer] The length of the line
    # @param options [Hash] Options for drawing the line
    # @option options [String] :char The character to use for the line
    # @option options [Symbol] :fg Foreground color
    # @option options [Symbol] :bg Background color
    # @return [void]
    def draw_vline(x, y, length, options = {})
      char = options[:char] || '│'
      
      length.times do |i|
        pos_y = y + i
        next if x < 0 || x >= @width || pos_y < 0 || pos_y >= @height
        
        @back_buffer[pos_y][x] = {
          char: char,
          fg: options[:fg],
          bg: options[:bg],
          style: options[:style]
        }
      end
    end
    
    # Draw a rectangle with various border styles
    # @param x [Integer] The x coordinate
    # @param y [Integer] The y coordinate
    # @param width [Integer] The width of the rectangle
    # @param height [Integer] The height of the rectangle
    # @param options [Hash] Options for drawing the rectangle
    # @option options [Boolean] :fill Whether to fill the rectangle
    # @option options [Symbol] :bg The background color
    # @option options [Symbol] :fg The foreground color
    # @option options [Symbol] :border_style The border style (:single, :double, :thick, :rounded)
    # @option options [Integer] :border_thickness The border thickness (1 or 2)
    # @option options [Boolean, Integer] :border_radius Whether to round the corners
    # @return [void]
    def draw_rect(x, y, width, height, options = {})
      if options[:fill]
        height.times do |dy|
          pos_y = y + dy
          next if pos_y < 0 || pos_y >= @height
          
          width.times do |dx|
            pos_x = x + dx
            next if pos_x < 0 || pos_x >= @width
            
            @back_buffer[pos_y][pos_x] = {
              char: ' ',
              fg: options[:fg],
              bg: options[:bg],
              style: options[:style]
            }
          end
        end
      else
        # Draw the horizontal lines
        draw_hline(x, y, width, options)
        draw_hline(x, y + height - 1, width, options)
        
        # Draw the vertical lines
        draw_vline(x, y, height, options)
        draw_vline(x + width - 1, y, height, options)
      end
      
      # Use border_color if provided, otherwise use fg
      border_color = options[:border_color] || options[:fg]
      
      # Draw the border with the specified color
      if options[:border]
        # Draw top and bottom borders
        draw_text(x, y, '─' * width, fg: border_color)
        draw_text(x, y + height - 1, '─' * width, fg: border_color)
        
        # Draw left and right borders
        (height - 2).times do |i|
          draw_text(x, y + i + 1, '│', fg: border_color)
          draw_text(x + width - 1, y + i + 1, '│', fg: border_color)
        end
      end
    end
    
    # Render the canvas to the terminal
    # @return [void]
    def render
      @terminal.hide_cursor
      
      # Check for changes and update only what's needed
      @height.times do |y|
        @width.times do |x|
          current = @current_buffer[y][x]
          back = @back_buffer[y][x]
          
          next if current == back
          
          @terminal.move_cursor(x, y)
          print ansi_format(back)
          print back[:char]
          
          # Update the current buffer
          @current_buffer[y][x] = back.dup
        end
      end
      
      # Swap buffers
      @current_buffer, @back_buffer = @back_buffer, @current_buffer
    end
    
    private
    
    def create_buffer
      Array.new(@height) { Array.new(@width) { { char: ' ', fg: nil, bg: nil, style: nil } } }
    end
    
    def ansi_format(cell)
      codes = []
      
      # Add foreground color
      if cell[:fg]
        color_code = color_to_ansi(cell[:fg])
        codes << color_code if color_code
      end
      
      # Add background color
      if cell[:bg]
        color_code = color_to_ansi(cell[:bg], true)
        codes << color_code if color_code
      end
      
      # Add style
      if cell[:style]
        style_code = style_to_ansi(cell[:style])
        codes << style_code if style_code
      end
      
      codes.empty? ? "\e[0m" : "\e[#{codes.join(';')}m"
    end
    
    def color_to_ansi(color, background = false)
      colors = {
        black: 0, red: 1, green: 2, yellow: 3,
        blue: 4, magenta: 5, cyan: 6, white: 7
      }
      
      base = background ? 40 : 30
      bright_base = background ? 100 : 90
      
      if color.to_s.start_with?('bright_')
        bright_color = color.to_s.sub('bright_', '').to_sym
        return bright_base + colors[bright_color] if colors.key?(bright_color)
      elsif colors.key?(color)
        return base + colors[color]
      end
      
      nil
    end
    
    def style_to_ansi(style)
      styles = {
        bold: 1, dim: 2, italic: 3, underline: 4,
        blink: 5, reverse: 7, hidden: 8, strikethrough: 9
      }
      
      styles[style]
    end
    
    # Draw a single-line border
    def draw_single_border(x, y, width, height, options)
      fg = options[:fg]
      radius = options[:radius]
      
      # Characters for single-line border
      if radius
        tl = '╭' # Top left
        tr = '╮' # Top right
        bl = '╰' # Bottom left
        br = '╯' # Bottom right
      else
        tl = '┌' # Top left
        tr = '┐' # Top right
        bl = '└' # Bottom left
        br = '┘' # Bottom right
      end
      
      h = '─'  # Horizontal
      v = '│'  # Vertical
      
      # Draw the border
      draw_border(x, y, width, height, tl, tr, bl, br, h, v, fg)
    end
    
    # Draw a double-line border
    def draw_double_border(x, y, width, height, options)
      fg = options[:fg]
      
      # Characters for double-line border
      tl = '╔' # Top left
      tr = '╗' # Top right
      bl = '╚' # Bottom left
      br = '╝' # Bottom right
      h = '═'  # Horizontal
      v = '║'  # Vertical
      
      # Draw the border
      draw_border(x, y, width, height, tl, tr, bl, br, h, v, fg)
    end
    
    # Draw a thick border
    def draw_thick_border(x, y, width, height, options)
      fg = options[:fg]
      
      # Characters for thick border
      tl = '▛' # Top left
      tr = '▜' # Top right
      bl = '▙' # Bottom left
      br = '▟' # Bottom right
      h = '▀'  # Horizontal top
      v = '▌'  # Vertical
      
      # Draw the border (simplified for thick border)
      draw_text(x, y, tl + h * (width - 2) + tr, fg: fg)
      (height - 2).times do |i|
        draw_text(x, y + i + 1, v + ' ' * (width - 2) + v, fg: fg)
      end
      draw_text(x, y + height - 1, bl + '▄' * (width - 2) + br, fg: fg)
    end
    
    # Draw a rounded border
    def draw_rounded_border(x, y, width, height, options)
      # This is the same as single border with radius=true
      draw_single_border(x, y, width, height, options.merge(radius: true))
    end
    
    # Helper method to draw a border with the given characters
    def draw_border(x, y, width, height, tl, tr, bl, br, h, v, fg)
      # Draw top and bottom borders
      draw_text(x, y, tl + h * (width - 2) + tr, fg: fg)
      draw_text(x, y + height - 1, bl + h * (width - 2) + br, fg: fg)
      
      # Draw left and right borders
      (height - 2).times do |i|
        draw_text(x, y + i + 1, v, fg: fg)
        draw_text(x + width - 1, y + i + 1, v, fg: fg)
      end
    end
  end
end 