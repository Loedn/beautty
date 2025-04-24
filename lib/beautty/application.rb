# frozen_string_literal: true

require_relative 'terminal'
require_relative 'container'

module Beautty
  # Main application class responsible for initializing the terminal,
  # running the event loop, and managing the root container.
  class Application
    attr_reader :container, :last_key

    # Initializes the application with a root component (typically a Container).
    def initialize(root_component)
      @container = root_component
      @running = false
      @last_key = nil
      @needs_redraw = true # Flag to trigger initial draw
    end

    # Starts the application, initializes Terminal, runs the event loop,
    # and ensures cleanup.
    def run
      @running = true
      init_terminal
      setup_signal_handlers
      main_loop
    ensure
      cleanup_terminal
    end

    private

    # Sets up the Terminal environment.
    def init_terminal
      Terminal.save_state
      Terminal.set_raw_mode
      Terminal.hide_cursor
      # Apply default styles/colors if needed
      # Terminal.write(Terminal::ANSI::FG_WHITE + Terminal::ANSI::BG_BLACK)
      Terminal.clear_screen # Initial clear
    end

    # Performs Terminal cleanup.
    def cleanup_terminal
      # puts "\nEntering cleanup_terminal..." # DEBUG
      # puts "Running cleanup steps..." # DEBUG
      # Clear the screen before restoring modes
      Terminal.clear_screen
      Terminal.show_cursor
      Terminal.write(Terminal::ANSI::RESET)
      Terminal.write("\n") # Ensure we are on a new line
      Terminal.restore_state # Calls cooked! and maybe stty
      @running = false # Still set running to false definitively
      # puts "Exiting cleanup_terminal." # DEBUG
    end
    
    # Sets up signal handlers (e.g., for window resize).
    def setup_signal_handlers
      Signal.trap('WINCH') do
        # Trigger resize handling logic
        # This runs async, so we set a flag for the main loop
        @needs_redraw = true 
        # Note: More robust handling might use a queue or pipe
        # to avoid race conditions if signal comes during input read.
        # For now, a simple flag check in the loop is okay.
        handle_resize # Handle resize immediately - simple approach
      end
      
      # Optional: Trap SIGINT (Ctrl+C) for graceful exit
      Signal.trap('INT') do
        @running = false
      end
    end

    # The main event processing loop.
    def main_loop
      while @running
        render if @needs_redraw
        handle_input # Waits for input
      end
    end

    # Renders the current UI state.
    def render
      # Recalculate layout before rendering using the LayoutEngine
      Beautty::LayoutEngine.calculate(@container)

      Terminal.clear_screen # Clear before redraw

      # Render the element tree using the Terminal module
      Terminal.render_element(@container)

      # Update status bar (if any)
      # Example: Terminal.move_cursor(Terminal.rows, 1)

      # 1. Draw the container's border
      @container.draw_border

      # 2. Draw Debug Info
      # Display the current size ON the top border
      size_info = "Size: #{@container.height}h x #{@container.width}w"
      # Ensure we don't write past the border width
      max_size_len = @container.width - 4 # Leave space for corners + padding
      size_info = size_info.slice(0, max_size_len) if size_info.length > max_size_len
      Terminal.move_cursor(1, 2) # Position ON top border, after corner (y=1, x=2)
      Terminal.write(" " * size_info.length) # Clear previous size (optional, but good practice)
      Terminal.move_cursor(1, 2)
      Terminal.write(size_info)

      # Display the last key pressed (keep inside border for now)
      if @last_key
        key_info = "Last Key: #{@last_key.inspect}"
        y_pos = 2 # Place on second line
        x_pos = @container.width - key_info.length # Adjust x to fit inside right border
        Terminal.move_cursor(y_pos, x_pos)
        Terminal.write(" " * key_info.length) # Clear previous key
        Terminal.move_cursor(y_pos, x_pos)
        Terminal.write(key_info)
      end

      # 3. Render container's children (they will draw themselves inside)
      @container.children.each(&:render)

      # No explicit refresh needed, Terminal.write flushes
      # Remove final cursor move
      @needs_redraw = false # Reset redraw flag
    end

    # Waits for and handles user input.
    def handle_input
      # Basic blocking read for now
      key = Terminal.read_input 
      @last_key = key
      @needs_redraw = true # Redraw after input to show last_key

      case key
      when 'q', 'Q', "\u0003" # Quit on q, Q, or Ctrl+C
        @running = false
      # when Curses::KEY_RESIZE -> Handled by SIGWINCH now
      # TODO: Add ANSI sequence parsing for arrow keys etc.
      else
        # Handle other keys
      end
    end

    # Handles terminal resize events (triggered by SIGWINCH).
    def handle_resize
      # Terminal.clear_screen is called by render now
      @container.handle_resize # Updates container dimensions
      @needs_redraw = true # Ensure redraw happens
      # Re-render immediately - simpler than just setting flag if signal safe
      render 
    end
  end
end 