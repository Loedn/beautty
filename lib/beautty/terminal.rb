# frozen_string_literal: true

require 'io/console' # For raw mode, getting size, etc.
require 'fcntl'     # For non-blocking read
require 'termios'   # For direct terminal settings manipulation

module Beautty
  # Provides low-level terminal interaction utilities using raw ANSI codes
  # and system calls, bypassing the curses library.
  module Terminal
    extend self # Make methods available directly on the module

    # ANSI Escape Code Constants
    module ANSI
      # Cursor Control
      CURSOR_UP    = "\e[A"
      CURSOR_DOWN  = "\e[B"
      CURSOR_RIGHT = "\e[C"
      CURSOR_LEFT  = "\e[D"
      CURSOR_POS   = "\e[%d;%dH" # Args: line, column (1-based)
      CURSOR_HIDE  = "\e[?25l"
      CURSOR_SHOW  = "\e[?25h"

      # Screen Control
      CLEAR_SCREEN = "\e[2J"
      CLEAR_LINE   = "\e[2K"

      # SGR (Select Graphic Rendition) - Colors/Styles
      RESET        = "\e[0m"
      BOLD         = "\e[1m"
      UNDERLINE    = "\e[4m"
      # Basic 8/16 Colors (Foreground)
      FG_BLACK     = "\e[30m"
      FG_RED       = "\e[31m"
      FG_GREEN     = "\e[32m"
      FG_YELLOW    = "\e[33m"
      FG_BLUE      = "\e[34m"
      FG_MAGENTA   = "\e[35m"
      FG_CYAN      = "\e[36m"
      FG_WHITE     = "\e[37m"
      # Basic 8/16 Colors (Background)
      BG_BLACK     = "\e[40m"
      BG_RED       = "\e[41m"
      BG_GREEN     = "\e[42m"
      BG_YELLOW    = "\e[43m"
      BG_BLUE      = "\e[44m"
      BG_MAGENTA   = "\e[45m"
      BG_CYAN      = "\e[46m"
      BG_WHITE     = "\e[47m"
      # TODO: Add 256/Truecolor support later if needed
    end

    # --- Terminal State Management ---
    @original_termios = nil

    def save_state
      # Save original termios settings
      if STDIN.isatty
        @original_termios = Termios.get(STDIN) rescue nil
      end
      # We can optionally still save stty -g as a fallback, but termios is preferred
      # @original_stty_state = `stty -g` rescue nil 
    end

    def restore_state
      # Rely solely on cooked! to reverse raw! effects.
      # Previous attempts with Termios.set and stty were ineffective.
      STDIN.cooked! rescue nil
      IO.console&.cooked! if IO.console&.respond_to?(:cooked!)
      # Explicitly try stty cooked as a final measure
      `stty cooked` rescue nil
    end

    def set_raw_mode
      # IO/console provides a cross-platform raw mode
      STDIN.raw! # Enables raw mode
    end

    def unset_raw_mode
      # IO/console provides a way to restore
      STDIN.cooked! # Disables raw mode
    end

    # --- Output Methods ---
    def write(str)
      STDOUT.write(str)
      STDOUT.flush # Ensure output is immediate
    end

    def move_cursor(line, col)
      write(format(ANSI::CURSOR_POS, line, col))
    end

    def clear_screen
      write(ANSI::CURSOR_POS % [1, 1]) # Move to top-left first
      write(ANSI::CLEAR_SCREEN)
    end

    def hide_cursor
      write(ANSI::CURSOR_HIDE)
    end

    def show_cursor
      write(ANSI::CURSOR_SHOW)
    end

    # --- Input Methods ---
    def read_input
      # Basic blocking read for now
      # TODO: Implement non-blocking read and ANSI sequence parsing
      STDIN.getc
    end

    # --- Terminal Information ---
    def get_size
      # IO/console provides a way to get size
      # Returns [rows, columns]
      IO.console.winsize rescue [24, 80] # Default fallback
    end

    def rows
      get_size[0]
    end

    def cols
      get_size[1]
    end

    # --- Rendering --- 
    # Recursively renders an element and its children using their calculated layout.
    # @param element [Beautty::Element] The element to render.
    def render_element(element)
      layout = element.layout

      # Don't render if layout is invalid or size is zero
      return unless layout && layout[:width] > 0 && layout[:height] > 0

      # --- Render the element itself ---
      # The element's own render method is responsible for drawing 
      # its content/border within its layout bounds (x, y, width, height).
      element.render # Call the element's specific render logic

      # --- Render children recursively ---
      element.children.each do |child|
        render_element(child)
      end
    end

  end
end 