# Main entry point for the Beautty framework
require_relative 'beautty/version'
require_relative 'beautty/terminal'
require_relative 'beautty/canvas'
require_relative 'beautty/style'
require_relative 'beautty/component'

# Components
require_relative 'beautty/components/box'
require_relative 'beautty/components/text'
require_relative 'beautty/components/footer'
require_relative 'beautty/components/navigation'
require_relative 'beautty/components/container'

module Beautty
  class Error < StandardError; end
  
  # Create a new application instance
  # @param block [Proc] The block to execute in the application context
  # @return [void]
  def self.application(&block)
    app = Application.new
    app.instance_eval(&block) if block_given?
    app
  end
  
  # Application class that manages the terminal and canvas
  class Application
    attr_reader :terminal, :canvas, :root_component
    
    def initialize
      @terminal = Terminal.new
      @canvas = Canvas.new(@terminal.width, @terminal.height)
      @root_component = Components::Box.new(
        style: {
          width: @terminal.width,
          height: @terminal.height
        }
      )
      setup_resize_handler
    end
    
    # Set the root component
    # @param component [Component] The root component
    # @return [void]
    def set_root(component)
      @root_component = component
    end
    
    # Start the application
    # @return [void]
    def start
      @terminal.raw_mode do
        # Initial layout calculation
        @root_component.calculate_layout(@terminal.width, @terminal.height)
        
        # Initial render
        render
        
        # Main event loop
        loop do
          input = @terminal.read_input
          break if input == "\u0003" # Ctrl+C
          
          # Pass input to the block if given
          yield @canvas, input if block_given?
          
          # Check for terminal resize
          if @terminal.check_resize
            @canvas.resize(@terminal.width, @terminal.height)
            @root_component.calculate_layout(@terminal.width, @terminal.height)
          end
          
          # Render the UI
          render
        end
      end
    ensure
      @terminal.reset
    end
    
    private
    
    def setup_resize_handler
      @terminal.on_resize do |width, height|
        @canvas.resize(width, height)
        @root_component.calculate_layout(width, height)
      end
    end
    
    def render
      @canvas.clear
      @root_component.render(@canvas)
      @canvas.render
    end
  end
end 