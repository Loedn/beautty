module Beautty
  # Base class for all UI components
  class Component
    attr_accessor :parent, :children, :style, :computed_style
    attr_accessor :x, :y, :width, :height
    attr_accessor :content_width, :content_height
    
    def initialize(options = {})
      @parent = nil
      @children = []
      @style = Style.new(options[:style] || {})
      @computed_style = nil
      
      # Position and size (will be calculated during layout)
      @x = 0
      @y = 0
      @width = 0
      @height = 0
      @content_width = 0
      @content_height = 0
      
      # Add any children
      if options[:children]
        options[:children].each { |child| add_child(child) }
      end
    end
    
    # Add a child component
    # @param child [Component] The child component to add
    # @return [Component] The added child
    def add_child(child)
      child.parent = self
      @children << child
      child
    end
    
    # Remove a child component
    # @param child [Component] The child component to remove
    # @return [Component, nil] The removed child or nil if not found
    def remove_child(child)
      if @children.include?(child)
        child.parent = nil
        @children.delete(child)
        return child
      end
      nil
    end
    
    # Calculate the layout of this component and its children
    # @param available_width [Integer] The available width
    # @param available_height [Integer] The available height
    # @param parent_style [Style] The parent's style for inheritance
    # @return [void]
    def calculate_layout(available_width, available_height, parent_style = nil)
      # Compute the style by merging with parent style
      @computed_style = parent_style ? parent_style.merge(@style) : @style.dup
      
      # Calculate the content size (without padding, border, margin)
      calculate_content_size(available_width, available_height)
      
      # Calculate the total size (including padding, border, margin)
      calculate_total_size
      
      # Layout children
      layout_children
    end
    
    # Calculate the content size of this component
    # @param max_width [Integer] The maximum available width
    # @param max_height [Integer] The maximum available height
    # @return [void]
    def calculate_content_size(max_width, max_height)
      # Handle symbolic width/height values
      width = @computed_style.width
      height = @computed_style.height
      
      # Convert :fill to the maximum available width/height
      width = max_width if width == :fill
      
      # Handle percentage values
      if width.is_a?(String) && width.end_with?('%')
        percentage = width.to_f / 100
        width = (max_width * percentage).to_i
      end
      
      # Same for height
      height = max_height if height == :fill
      
      if height.is_a?(String) && height.end_with?('%')
        percentage = height.to_f / 100
        height = (max_height * percentage).to_i
      end
      
      # Use explicit width/height if provided
      @content_width = width.is_a?(Numeric) ? width : 0
      @content_height = height.is_a?(Numeric) ? height : 0
      
      # If no explicit width/height, calculate based on children
      if @content_width == 0 || @content_height == 0
        # Default implementation - use available space or explicit size
        style = @computed_style
        
        # Calculate available space after padding and margin
        h_spacing = style.padding[:left] + style.padding[:right] + 
                    style.margin[:left] + style.margin[:right]
        v_spacing = style.padding[:top] + style.padding[:bottom] + 
                    style.margin[:top] + style.margin[:bottom]
        
        # Add border if present
        h_spacing += 2 if style.border
        v_spacing += 2 if style.border
        
        # Calculate content dimensions
        available_content_width = [max_width - h_spacing, 0].max
        available_content_height = [max_height - v_spacing, 0].max
        
        # Use explicit width/height if provided, otherwise use available space
        @content_width = style.width || available_content_width
        @content_height = style.height || available_content_height
        
        # Apply min/max constraints
        @content_width = [[@content_width, style.min_width].max, style.max_width || Float::INFINITY].min
        @content_height = [[@content_height, style.min_height].max, style.max_height || Float::INFINITY].min
      end
    end
    
    # Calculate the total size of this component including padding, border, margin
    # @return [void]
    def calculate_total_size
      style = @computed_style
      
      # Add padding
      @width = @content_width + style.padding[:left] + style.padding[:right]
      @height = @content_height + style.padding[:top] + style.padding[:bottom]
      
      # Add border
      if style.border
        @width += 2
        @height += 2
      end
      
      # Add margin (doesn't affect size, but affects positioning)
    end
    
    # Layout the children of this component
    # @return [void]
    def layout_children
      return if @children.empty?
      
      style = @computed_style
      
      # Calculate content area (where children will be placed)
      content_x = style.padding[:left]
      content_y = style.padding[:top]
      
      # Add border offset if present
      if style.border
        content_x += 1
        content_y += 1
      end
      
      # Adjust for flex direction
      if style.display == :flex
        if style.flex_direction == :row
          layout_flex_row(content_x, content_y)
        else # :column
          layout_flex_column(content_x, content_y)
        end
      else
        # Default block layout - stack vertically
        layout_block(content_x, content_y)
      end
    end
    
    # Layout children in a flex row
    # @param content_x [Integer] The x coordinate of the content area
    # @param content_y [Integer] The y coordinate of the content area
    # @return [void]
    def layout_flex_row(content_x, content_y)
      style = @computed_style
      
      # Calculate total flex grow and initial space used
      total_flex_grow = 0
      total_flex_basis = 0
      
      @children.each do |child|
        child_style = child.style
        total_flex_grow += child_style.flex_grow
        
        # Calculate flex basis
        if child_style.flex_basis == :auto
          # Auto means use the child's width
          child.calculate_layout(@content_width, @content_height, @computed_style)
          total_flex_basis += child.width
        else
          # Use the specified flex basis
          total_flex_basis += child_style.flex_basis
        end
      end
      
      # Calculate remaining space
      remaining_space = [@content_width - total_flex_basis, 0].max
      
      # Distribute remaining space according to flex grow
      x_offset = content_x
      
      @children.each do |child|
        child_style = child.style
        
        # Calculate child's width based on flex grow
        extra_width = 0
        if total_flex_grow > 0 && child_style.flex_grow > 0
          extra_width = (remaining_space * child_style.flex_grow / total_flex_grow).floor
        end
        
        # Calculate available width for this child
        child_width = if child_style.flex_basis == :auto
                        child.width + extra_width
                      else
                        child_style.flex_basis + extra_width
                      end
        
        # Layout the child
        child.calculate_layout(child_width, @content_height, @computed_style)
        
        # Position the child
        child.x = x_offset
        
        # Apply alignment
        case style.align_items
        when :flex_start
          child.y = content_y
        when :flex_end
          child.y = content_y + @content_height - child.height
        when :center
          child.y = content_y + (@content_height - child.height) / 2
        when :stretch
          # Stretch to fill the container height
          child.height = @content_height
          child.y = content_y
        end
        
        # Move to the next position
        x_offset += child.width
      end
      
      # Apply justify content
      if style.justify_content != :flex_start && x_offset < content_x + @content_width
        extra_space = content_x + @content_width - x_offset
        
        case style.justify_content
        when :flex_end
          # Move all children to the end
          @children.each { |child| child.x += extra_space }
        when :center
          # Center all children
          @children.each { |child| child.x += extra_space / 2 }
        when :space_between
          # Distribute space between children
          if @children.length > 1
            space_per_gap = extra_space / (@children.length - 1)
            @children.each_with_index do |child, index|
              child.x += space_per_gap * index
            end
          end
        when :space_around
          # Distribute space around children
          if @children.length > 0
            space_per_child = extra_space / @children.length
            @children.each_with_index do |child, index|
              child.x += space_per_child * (index + 0.5)
            end
          end
        end
      end
    end
    
    # Layout children in a flex column
    # @param content_x [Integer] The x coordinate of the content area
    # @param content_y [Integer] The y coordinate of the content area
    # @return [void]
    def layout_flex_column(content_x, content_y)
      style = @computed_style
      
      # Calculate total flex grow and initial space used
      total_flex_grow = 0
      total_flex_basis = 0
      
      @children.each do |child|
        child_style = child.style
        total_flex_grow += child_style.flex_grow
        
        # Calculate flex basis
        if child_style.flex_basis == :auto
          # Auto means use the child's height
          child.calculate_layout(@content_width, @content_height, @computed_style)
          total_flex_basis += child.height
        else
          # Use the specified flex basis
          total_flex_basis += child_style.flex_basis
        end
      end
      
      # Calculate remaining space
      remaining_space = [@content_height - total_flex_basis, 0].max
      
      # Distribute remaining space according to flex grow
      y_offset = content_y
      
      @children.each do |child|
        child_style = child.style
        
        # Calculate child's height based on flex grow
        extra_height = 0
        if total_flex_grow > 0 && child_style.flex_grow > 0
          extra_height = (remaining_space * child_style.flex_grow / total_flex_grow).floor
        end
        
        # Calculate available height for this child
        child_height = if child_style.flex_basis == :auto
                         child.height + extra_height
                       else
                         child_style.flex_basis + extra_height
                       end
        
        # Layout the child
        child.calculate_layout(@content_width, child_height, @computed_style)
        
        # Position the child
        child.y = y_offset
        
        # Apply alignment
        case style.align_items
        when :flex_start
          child.x = content_x
        when :flex_end
          child.x = content_x + @content_width - child.width
        when :center
          child.x = content_x + (@content_width - child.width) / 2
        when :stretch
          # Stretch to fill the container width
          child.width = @content_width
          child.x = content_x
        end
        
        # Move to the next position
        y_offset += child.height
      end
      
      # Apply justify content
      if style.justify_content != :flex_start && y_offset < content_y + @content_height
        extra_space = content_y + @content_height - y_offset
        
        case style.justify_content
        when :flex_end
          # Move all children to the end
          @children.each { |child| child.y += extra_space }
        when :center
          # Center all children
          @children.each { |child| child.y += extra_space / 2 }
        when :space_between
          # Distribute space between children
          if @children.length > 1
            space_per_gap = extra_space / (@children.length - 1)
            @children.each_with_index do |child, index|
              child.y += space_per_gap * index
            end
          end
        when :space_around
          # Distribute space around children
          if @children.length > 0
            space_per_child = extra_space / @children.length
            @children.each_with_index do |child, index|
              child.y += space_per_child * (index + 0.5)
            end
          end
        end
      end
    end
    
    # Layout children in a block layout (stacked vertically)
    # @param content_x [Integer] The x coordinate of the content area
    # @param content_y [Integer] The y coordinate of the content area
    # @return [void]
    def layout_block(content_x, content_y)
      y_offset = content_y
      
      @children.each do |child|
        # Layout the child
        child.calculate_layout(@content_width, @content_height - (y_offset - content_y), @computed_style)
        
        # Position the child
        child.x = content_x
        child.y = y_offset
        
        # Move to the next position
        y_offset += child.height
      end
    end
    
    # Render this component and its children to the canvas
    # @param canvas [Canvas] The canvas to render to
    # @param offset_x [Integer] The x offset for rendering
    # @param offset_y [Integer] The y offset for rendering
    # @return [void]
    def render(canvas, offset_x = 0, offset_y = 0)
      return unless @computed_style
      
      style = @computed_style
      abs_x = @x + offset_x
      abs_y = @y + offset_y
      
      # Draw background if specified
      if style.bg
        canvas.draw_rect(abs_x, abs_y, @width, @height, fill: true, bg: style.bg)
      end
      
      # Draw border if specified
      if style.border
        border_style = { fg: style.fg }
        canvas.draw_rect(abs_x, abs_y, @width, @height, border_style)
      end
      
      # Render children
      @children.each do |child|
        child.render(canvas, abs_x, abs_y)
      end
    end
    
    # Render all children of this component
    # @param canvas [Canvas] The canvas to render to
    # @param offset_x [Integer] The x offset to apply
    # @param offset_y [Integer] The y offset to apply
    # @return [void]
    def render_children(canvas, offset_x = 0, offset_y = 0)
      # Calculate content area offset (accounting for padding and border)
      content_offset_x = offset_x
      content_offset_y = offset_y
      
      # Add padding offset
      content_offset_x += @computed_style.padding[:left]
      content_offset_y += @computed_style.padding[:top]
      
      # Add border offset if present
      if @computed_style.border
        content_offset_x += 1
        content_offset_y += 1
      end
      
      # Render each child
      @children.each do |child|
        child.render(canvas, content_offset_x, content_offset_y)
      end
    end
  end
end 