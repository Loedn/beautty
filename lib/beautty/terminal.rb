require 'io/console'

module Beautty
  # Handles terminal interactions
  class Terminal
    attr_reader :width, :height
    
    def initialize
      update_size
      @resize_callbacks = []
    end
    
    # Update the stored terminal size
    # @return [Array<Integer>] The width and height of the terminal
    def update_size
      @height, @width = IO.console.winsize
      [@width, @height]
    end
    
    # Register a callback for terminal resize events
    # @param block [Proc] The callback to execute when the terminal is resized
    # @return [void]
    def on_resize(&block)
      @resize_callbacks << block if block_given?
    end
    
    # Check if the terminal has been resized and trigger callbacks if it has
    # @return [Boolean] True if the terminal was resized
    def check_resize
      old_width, old_height = @width, @height
      new_width, new_height = update_size
      
      if new_width != old_width || new_height != old_height
        @resize_callbacks.each { |callback| callback.call(new_width, new_height) }
        return true
      end
      
      false
    end
    
    # Put the terminal in raw mode for the duration of the block
    # @param block [Proc] The block to execute in raw mode
    # @return [void]
    def raw_mode
      IO.console.raw!
      IO.console.echo = false
      yield if block_given?
    ensure
      reset
    end
    
    # Reset the terminal to normal mode
    # @return [void]
    def reset
      IO.console.cooked!
      IO.console.echo = true
      print "\e[?25h" # Show cursor
      print "\e[0m"   # Reset all attributes
    end
    
    # Read a single keystroke from the terminal
    # @return [String] The character read
    def read_input
      IO.console.getch
    end
    
    # Move the cursor to a specific position
    # @param x [Integer] The x coordinate (column)
    # @param y [Integer] The y coordinate (row)
    # @return [void]
    def move_cursor(x, y)
      print "\e[#{y + 1};#{x + 1}H"
    end
    
    # Hide the cursor
    # @return [void]
    def hide_cursor
      print "\e[?25l"
    end
    
    # Show the cursor
    # @return [void]
    def show_cursor
      print "\e[?25h"
    end
    
    # Clear the screen
    # @return [void]
    def clear_screen
      print "\e[2J\e[H"
    end
  end
end 