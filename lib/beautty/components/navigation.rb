module Beautty
  module Components
    # A navigation component that displays tabs and renders different views
    class Navigation < Component
      attr_reader :tabs, :active_tab_index
      
      def initialize(options = {})
        super(options)
        @tabs = []
        @active_tab_index = 0
        @tab_views = {}
        
        # Set default styles for navigation
        @style = Style.new({
          width: '100%',
          display: :flex,
          flex_direction: :column
        }).merge(@style)
        
        # Add initial tabs if provided
        if options[:tabs]
          options[:tabs].each do |tab|
            add_tab(tab[:id], tab[:title], tab[:content])
          end
        end
        
        # Set active tab if provided
        @active_tab_index = options[:active_tab] || 0
      end
      
      # Add a new tab
      # @param id [Symbol, String] The unique identifier for the tab
      # @param title [String] The title to display in the tab
      # @param content [Component] The component to display when the tab is active
      # @return [void]
      def add_tab(id, title, content)
        @tabs << { id: id, title: title }
        @tab_views[id] = content
        
        # If this is the first tab, make it active
        @active_tab_index = 0 if @tabs.length == 1
        
        # Rebuild the navigation UI
        rebuild_navigation
      end
      
      # Remove a tab by ID
      # @param id [Symbol, String] The ID of the tab to remove
      # @return [void]
      def remove_tab(id)
        index = @tabs.index { |tab| tab[:id] == id }
        return unless index
        
        @tabs.delete_at(index)
        @tab_views.delete(id)
        
        # Adjust active tab index if needed
        if @active_tab_index >= @tabs.length
          @active_tab_index = [@tabs.length - 1, 0].max
        end
        
        # Rebuild the navigation UI
        rebuild_navigation
      end
      
      # Set the active tab by ID
      # @param id [Symbol, String] The ID of the tab to activate
      # @return [void]
      def set_active_tab(id)
        index = @tabs.index { |tab| tab[:id] == id }
        return unless index
        
        @active_tab_index = index
        rebuild_navigation
      end
      
      # Set the active tab by index
      # @param index [Integer] The index of the tab to activate
      # @return [void]
      def set_active_tab_index(index)
        return unless index >= 0 && index < @tabs.length
        
        @active_tab_index = index
        rebuild_navigation
      end
      
      # Get the active tab ID
      # @return [Symbol, String] The ID of the active tab
      def active_tab_id
        return nil if @tabs.empty?
        @tabs[@active_tab_index][:id]
      end
      
      # Get the active tab content
      # @return [Component] The content component of the active tab
      def active_tab_content
        return nil if @tabs.empty?
        @tab_views[@tabs[@active_tab_index][:id]]
      end
      
      # Move to the next tab
      # @return [void]
      def next_tab
        return if @tabs.empty?
        @active_tab_index = (@active_tab_index + 1) % @tabs.length
        rebuild_navigation
      end
      
      # Move to the previous tab
      # @return [void]
      def previous_tab
        return if @tabs.empty?
        @active_tab_index = (@active_tab_index - 1) % @tabs.length
        rebuild_navigation
      end
      
      private
      
      # Rebuild the navigation UI
      def rebuild_navigation
        # Clear existing children
        @children.clear
        
        # Create the tab bar (horizontal navbar)
        tab_bar = Box.new(
          style: {
            height: 3,
            width: '100%',
            display: :flex,
            flex_direction: :row,
            bg: :blue,
            border: false,  # Remove border from the tab bar container
            padding: [0, 0, 0, 0]
          }
        )
        
        # Calculate approximate width for each tab based on number of tabs
        # This ensures tabs are evenly distributed across the width
        
        # Add tabs to the tab bar
        @tabs.each_with_index do |tab, index|
          is_active = index == @active_tab_index
          
          # Create a more navbar-like tab
          tab_box = Box.new(
            style: {
              flex_grow: 1,  # Make tabs take equal space
              height: 3,
              padding: [0, 0, 0, 0],
              margin: [0, 0, 0, 0],
              bg: is_active ? :white : :blue,
              border: false  # No border for individual tabs
            }
          )
          
          # Add the tab text centered in the tab
          tab_box.add_child(
            Text.new(
              tab[:title],
              style: {
                fg: is_active ? :black : :white,
                style: is_active ? :bold : nil,
                padding: [1, 0, 0, 0]  # Center text vertically
              }
            )
          )
          
          # Add a bottom border/indicator for the active tab
          if is_active
            # Add a visual indicator for the active tab (like an underline)
            underline = Box.new(
              style: {
                height: 1,
                width: '100%',
                bg: :bright_white,
                margin: [2, 0, 0, 0]  # Position at the bottom
              }
            )
            tab_box.add_child(underline)
          end
          
          tab_bar.add_child(tab_box)
        end
        
        # Add the tab bar to the navigation
        add_child(tab_bar)
        
        # Add the content area
        content_area = Box.new(
          style: {
            flex_grow: 1,
            border: true,
            border_style: :rounded
          }
        )
        
        # Add the active tab content to the content area
        if active_tab_content
          content_area.add_child(active_tab_content)
        end
        
        # Add the content area to the navigation
        add_child(content_area)
      end
    end
  end
end 