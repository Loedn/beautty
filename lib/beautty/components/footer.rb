module Beautty
  module Components
    # A footer component that always displays at the bottom of the screen
    class Footer < Component
      attr_accessor :commands
      
      def initialize(options = {})
        super(options)
        @commands = options[:commands] || {}
        
        # Set default styles for footer
        @style = Style.new({
          height: 3,
          width: '100%',
          bg: :blue,
          border: true,
          padding: [1, 2, 1, 2]
        }).merge(@style)
      end
      
      # Add a command to the footer
      # @param key [String] The key to press
      # @param description [String] The description of what the key does
      # @return [void]
      def add_command(key, description)
        @commands[key] = description
        update_command_text
      end
      
      # Remove a command from the footer
      # @param key [String] The key to remove
      # @return [void]
      def remove_command(key)
        @commands.delete(key)
        update_command_text
      end
      
      # Clear all commands
      # @return [void]
      def clear_commands
        @commands.clear
        update_command_text
      end
      
      private
      
      # Update the text component with the current commands
      def update_command_text
        # Clear existing children
        @children.clear
        
        # Create the command text
        command_text = @commands.map { |key, desc| "#{key}: #{desc}" }.join("  ")
        
        # Add the text component
        add_child(
          Text.new(
            command_text,
            style: {
              fg: :white
            }
          )
        )
      end
    end
  end
end 