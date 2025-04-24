# frozen_string_literal: true

require_relative 'test_helper'
require 'stringio'

class TerminalTest < Minitest::Test
  def setup
    # Keep original methods
    @original_stdin = STDIN
    @original_stdout = STDOUT
    @original_io_console = IO.method(:console) if IO.respond_to?(:console)

    # Mock STDOUT to capture output
    @mock_stdout = StringIO.new
    Object.const_set(:STDOUT, @mock_stdout)

    # Mock STDIN methods
    @mock_stdin = Minitest::Mock.new
    Object.const_set(:STDIN, @mock_stdin)

    # Mock IO.console methods
    @mock_console = Minitest::Mock.new
    # Need to mock cooked! now for restore_state test
    # @mock_console.expect(:cooked!, nil) if @mock_console.respond_to?(:cooked!)
    IO.singleton_class.send(:define_method, :console) { @mock_console }

    # Mock Termios methods
    @mock_termios_obj = Object.new # Dummy object to represent termios struct
    Termios.singleton_class.send(:alias_method, :original_get, :get)
    Termios.singleton_class.send(:define_method, :get) do |_fd|
      @mock_termios_obj # Return our dummy object
    end
    # Termios.set is no longer called in restore_state
    # Termios.singleton_class.send(:alias_method, :original_set, :set)
    # @set_called_with = nil # Track calls to set
    # Termios.singleton_class.send(:define_method, :set) do |_fd, termios_obj|
    #   @set_called_with = termios_obj # Store the passed object
    #   nil # Return value doesn't matter much
    # end

    # Mock Kernel backtick method for stty calls (no longer needed in restore_state)
    @original_backtick = Kernel.method(:`)
    Kernel.define_singleton_method(:`) do |command|
      case command
      # Allow stty -g for save_state if we re-enable it later
      # when 'stty -g'
      #   "SAVED_STTY_STATE\n"
      when 'stty cooked'
        "" # Simulate successful explicit restore
      else
        raise "Unexpected command: #{command}"
      end
    end

    # Clear any stored state in the module before each test
    Beautty::Terminal.instance_variable_set(:@original_termios, nil)
  end

  def teardown
    # Restore original constants and methods
    Object.const_set(:STDIN, @original_stdin)
    Object.const_set(:STDOUT, @original_stdout)
    if @original_io_console
      IO.singleton_class.send(:define_method, :console, @original_io_console)
    else
      # If IO.console didn't exist originally, remove the mock
      IO.singleton_class.send(:remove_method, :console) rescue nil # Rescue if already removed
    end
    # Restore Termios get (set wasn't mocked)
    Termios.singleton_class.send(:alias_method, :get, :original_get)
    Termios.singleton_class.send(:remove_method, :original_get)
    # Termios.singleton_class.send(:alias_method, :set, :original_set)
    # Termios.singleton_class.send(:remove_method, :original_set)
    # Restore backtick
    Kernel.define_singleton_method(:`, @original_backtick)
  end

  # --- Helper to get output --- 
  def stdout_output
    @mock_stdout.rewind
    @mock_stdout.read
  end

  # --- State Management Tests ---
  def test_save_state
    @mock_stdin.expect(:isatty, true) # Assume it's a TTY
    Beautty::Terminal.save_state
    assert_equal @mock_termios_obj, Beautty::Terminal.instance_variable_get(:@original_termios)
    @mock_stdin.verify
  end

  def test_restore_state
    # Set the saved state (though not used by restore now)
    Beautty::Terminal.instance_variable_set(:@original_termios, @mock_termios_obj)
    # Expect STDIN checks and IO.console checks
    # @mock_stdin.expect(:isatty, true) # No longer checked in restore
    @mock_stdin.expect(:cooked!, nil)
    # Ensure IO.console mock is available for respond_to?
    IO.singleton_class.send(:define_method, :console) { @mock_console } 
    @mock_console.expect(:respond_to?, true, [:cooked!])
    @mock_console.expect(:cooked!, nil)
    
    Beautty::Terminal.restore_state
    
    # Check that cooked! methods were called
    # assert_equal @mock_termios_obj, @set_called_with # Termios.set no longer called
    # Note: Verification of the backtick call is implicit (raises error if wrong command)
    @mock_stdin.verify
    @mock_console.verify
  end

  def test_set_raw_mode
    @mock_stdin.expect(:raw!, nil)
    Beautty::Terminal.set_raw_mode
    @mock_stdin.verify
  end

  def test_unset_raw_mode
    @mock_stdin.expect(:cooked!, nil)
    Beautty::Terminal.unset_raw_mode
    @mock_stdin.verify
  end

  # --- Output Tests ---
  def test_write
    Beautty::Terminal.write("hello")
    assert_equal "hello", stdout_output
  end

  def test_move_cursor
    Beautty::Terminal.move_cursor(5, 10)
    assert_equal "\e[5;10H", stdout_output
  end

  def test_clear_screen
    Beautty::Terminal.clear_screen
    assert_equal "\e[1;1H\e[2J", stdout_output
  end

  def test_hide_cursor
    Beautty::Terminal.hide_cursor
    assert_equal "\e[?25l", stdout_output
  end

  def test_show_cursor
    Beautty::Terminal.show_cursor
    assert_equal "\e[?25h", stdout_output
  end

  # --- Input Tests ---
  def test_read_input
    @mock_stdin.expect(:getc, 'a')
    assert_equal 'a', Beautty::Terminal.read_input
    @mock_stdin.verify
  end

  # --- Info Tests ---
  def test_get_size_success
    @mock_console.expect(:winsize, [24, 80])
    assert_equal [24, 80], Beautty::Terminal.get_size
    @mock_console.verify
  end
  
  def test_get_size_failure_fallback
    # Make winsize raise an error
    @mock_console.expect(:winsize, nil) { raise NoMethodError }
    assert_equal [24, 80], Beautty::Terminal.get_size
    @mock_console.verify # Verify it was called
  end

  def test_rows
    @mock_console.expect(:winsize, [30, 100])
    assert_equal 30, Beautty::Terminal.rows
    @mock_console.verify 
  end

  def test_cols
    @mock_console.expect(:winsize, [30, 100])
    assert_equal 100, Beautty::Terminal.cols
    @mock_console.verify 
  end
end 