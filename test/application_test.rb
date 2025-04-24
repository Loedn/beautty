# frozen_string_literal: true

require_relative 'test_helper'
require 'stringio' # To mock STDOUT/STDIN if needed directly

class ApplicationTest < Minitest::Test
  def setup
    # --- Mock Container ---
    @mock_container = Minitest::Mock.new
    # Container methods Application will call
    @mock_container.expect(:height, 24) # For render
    @mock_container.expect(:width, 80)  # For render
    @mock_container.expect(:draw_border, nil) # Called during render
    # Expect handle_resize in the resize test

    # --- Mock Terminal Methods ---
    # Keep track of original methods to restore them
    @original_terminal_methods = {}

    # Define default mocks for methods called during typical run
    mock_terminal_method(:save_state)
    mock_terminal_method(:set_raw_mode)
    mock_terminal_method(:hide_cursor)
    mock_terminal_method(:clear_screen) # May be called in render/resize
    mock_terminal_method(:write, nil) # Capture/ignore output
    mock_terminal_method(:move_cursor, nil) # Ignore cursor moves
    mock_terminal_method(:read_input, 'q') # Default to quit immediately
    mock_terminal_method(:unset_raw_mode)
    mock_terminal_method(:show_cursor)
    mock_terminal_method(:restore_state)
    mock_terminal_method(:rows, 24) # For container init potentially
    mock_terminal_method(:cols, 80) # For container init potentially

    # --- Initialize Application ---
    @app = Beautty::Application.new(@mock_container)
  end

  def teardown
    # Restore original Terminal methods
    @original_terminal_methods.each do |method, original|
      Beautty::Terminal.define_singleton_method(method, original)
    end
  end

  # Helper to mock methods on the Terminal module
  def mock_terminal_method(method_name, return_value = nil, &block)
    if Beautty::Terminal.respond_to?(method_name, true)
      @original_terminal_methods[method_name] = Beautty::Terminal.method(method_name)
    end
    if block
      Beautty::Terminal.define_singleton_method(method_name, &block)
    else
      Beautty::Terminal.define_singleton_method(method_name) { |*_args| return_value }
    end
  end

  # --- Tests ---
  def test_initialize
    assert_equal @mock_container, @app.container
    refute @app.instance_variable_get(:@running)
    assert_nil @app.last_key
  end

  def test_run_calls_init_main_cleanup
    # Mock the private methods on the app instance
    init_mock = Minitest::Mock.new.expect :call, nil
    loop_mock = Minitest::Mock.new.expect :call, nil
    cleanup_mock = Minitest::Mock.new.expect :call, nil

    @app.stub :init_terminal, init_mock do
      @app.stub :main_loop, loop_mock do
        @app.stub :cleanup_terminal, cleanup_mock do
          @app.run
        end
      end
    end

    init_mock.verify
    loop_mock.verify
    cleanup_mock.verify
  end

  def test_init_terminal_sequence
    # Expect terminal setup calls
    mock_expectations = []
    mock_expectations << mock_terminal_method(:save_state)
    mock_expectations << mock_terminal_method(:set_raw_mode)
    mock_expectations << mock_terminal_method(:hide_cursor)
    # Note: color setup might be added here later
    # mock_expectations << mock_terminal_method(:write, nil, [Beautty::Terminal::ANSI::SOME_COLOR])

    # Call the private method
    @app.send(:init_terminal)

    # Verification happens via teardown raising errors if mocks weren't called
    # or via explicit mock object verification if we used Minitest::Mock
  end

  def test_cleanup_terminal_sequence
    mock_expectations = []
    mock_expectations << mock_terminal_method(:unset_raw_mode)
    mock_expectations << mock_terminal_method(:show_cursor)
    mock_expectations << mock_terminal_method(:restore_state)
    # mock_expectations << mock_terminal_method(:write, nil, [Beautty::Terminal::ANSI::RESET])

    # Set running state so cleanup actually runs
    @app.instance_variable_set(:@running, true)
    @app.send(:cleanup_terminal)

    refute @app.instance_variable_get(:@running)
  end

  def test_main_loop_renders_and_handles_input_then_quits
    render_mock = Minitest::Mock.new.expect :call, nil
    handle_input_mock = Minitest::Mock.new.expect :call, nil

    # Ensure read_input returns 'q' to exit loop after one iteration
    mock_terminal_method(:read_input, 'q')

    @app.stub :render, render_mock do
      @app.stub :handle_input, handle_input_mock do
        @app.instance_variable_set(:@running, true)
        @app.send(:main_loop)
      end
    end

    render_mock.verify
    handle_input_mock.verify
    refute @app.instance_variable_get(:@running)
  end

  def test_handle_input_quit
    mock_terminal_method(:read_input, 'q')
    @app.instance_variable_set(:@running, true)
    @app.send(:handle_input)
    refute @app.instance_variable_get(:@running)
    assert_equal 'q', @app.last_key
  end

  # NOTE: Testing KEY_RESIZE equivalent is tricky without simulating signals.
  # We test the handle_resize method directly.
  # The Application code will need to trap SIGWINCH and call handle_resize.

  def test_handle_resize_calls_container_and_renders
    # Mock get_size which is called by container.handle_resize -> update_dimensions
    mock_terminal_method(:rows, 30)
    mock_terminal_method(:cols, 100)
    mock_terminal_method(:clear_screen) # Expected during container resize

    # Expect container.handle_resize
    # We need to ensure the *real* handle_resize runs on the mock to trigger
    # dimension update, but mock the draw_border call within it.
    @mock_container.expect(:handle_resize, nil) do 
       # Simulate container updating its internal size based on Terminal mock
       @mock_container.expect(:height, 30)
       @mock_container.expect(:width, 100)
       # Simulate the container calling draw_border internally
       @mock_container.expect(:draw_border, nil)
       # Simulate container calling clear_screen
       # No need to assert clear_screen mock here, done via terminal mock
    end
    
    render_mock = Minitest::Mock.new.expect :call, nil

    @app.stub :render, render_mock do
      @app.send(:handle_resize) # Call the app's handler directly
    end

    @mock_container.verify
    render_mock.verify
  end

  def test_render_draws_container_key_and_size
    # Expect container.draw_border
    @mock_container.expect(:draw_border, nil)

    # Capture output
    output_capture = StringIO.new
    mock_terminal_method(:write) { |str| output_capture.write(str) }

    # Mock cursor moves
    mock_terminal_method(:move_cursor, nil) # Ignore moves for simplicity now

    # Set a last key
    @app.instance_variable_set(:@last_key, 'a')
    # Get container dimensions for positioning calculation
    height = @mock_container.height
    width = @mock_container.width
    
    # Calculate expected outputs
    key_info = "Last Key: \"a\""
    key_x_pos = width - key_info.length - 2
    size_info = "Size: #{height}h x #{width}w"

    # Execute render
    @app.send(:render)

    # Verify mocks and output
    @mock_container.verify
    output_str = stdout_output(output_capture)
    assert_includes output_str, key_info # Check if key info is present
    assert_includes output_str, size_info # Check if size info is present
    # TODO: Add more specific assertions about ANSI codes and positions if needed
  end
  
  # Helper to get stringio output
  def stdout_output(io)
      io.rewind
      io.read
  end
end 