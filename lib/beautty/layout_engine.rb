# frozen_string_literal: true

module Beautty
  # Responsible for calculating the layout (position and dimensions) of elements
  # based on Flexbox rules defined in their styles.
  module LayoutEngine
    extend self

    # Calculates the layout for the given element and its descendants.
    # Updates the `layout` hash ({:x, :y, :width, :height}) on each element.
    # @param element [Element] The root element of the tree/subtree to lay out.
    def calculate(element)
      # Start recursive layout calculation from the root
      layout_node(element)
    end

    private

    # Recursive function to lay out a single node and its children.
    # Determines the node's own size and then distributes space to children.
    # @param element [Element] The element to lay out.
    # @param parent_layout [Hash] The layout context from the parent (position, available size).
    def layout_node(element, parent_layout = { x: 0, y: 0, width: Terminal.cols, height: Terminal.rows })
      # --- 1. Determine Border Size ---
      border_size = (element.style[:border] && element.style[:border] != :none) ? 1 : 0
      # For Container, border is always assumed for now
      border_size = 1 if element.is_a?(Beautty::Container) 

      # --- 2. Determine Available Content Space (Inside Borders) ---
      # Start position is parent's position
      my_x = parent_layout[:x]
      my_y = parent_layout[:y]
      # Available space for the *whole* element (including border)
      parent_available_width = parent_layout[:width]
      parent_available_height = parent_layout[:height]

      # Content area calculation (subtract border from available space)
      content_x = my_x + border_size
      content_y = my_y + border_size
      available_width = [parent_available_width - (border_size * 2), 0].max
      available_height = [parent_available_height - (border_size * 2), 0].max

      # --- 3. Calculate Children Layout based on Flex Direction ---
      children = element.children
      # Note: flex_basis/grow/shrink default to 0 if not specified in style
      flex_direction = element.style[:flex_direction] || :column 

      # Lay out children within the calculated content area
      justify_content = element.style[:justify_content] || :flex_start # Default

      if flex_direction == :row
        # Pass available_height and align_items for cross-axis constraints
        align_items = element.style[:align_items] || :stretch # Default to stretch
        layout_children_row(children, content_x, content_y, available_width, available_height, align_items, justify_content)
      elsif flex_direction == :column && !children.empty?
        # --- Column Layout with Flex-Grow --- 
        
        # --- Pass 1: Measure Preferred Height & Sum Grow Factors --- 
        total_preferred_height = 0
        total_grow = 0.0
        child_preferred_heights = {}

        children.each do |child|
          # Estimate preferred size by laying out with available width but unconstrained height
          temp_parent_layout = { x: content_x, y: content_y, width: available_width, height: Float::INFINITY }
          layout_node(child, temp_parent_layout) # Recursive call for measurement
          preferred_height = child.layout[:height]
          child_preferred_heights[child] = preferred_height
          total_preferred_height += preferred_height

          grow_factor = child.style[:flex_grow].to_f || 0.0
          if grow_factor > 0
            total_grow += grow_factor
          end
        end

        # --- Calculate Distribution --- 
        extra_height = available_height - total_preferred_height
        height_per_grow_unit = (total_grow > 0 && extra_height > 0) ? (extra_height / total_grow) : 0
        # TODO: Handle remainder distribution for pixel perfection

        # --- Calculate Justify Content Offset (Column) --- 
        provisional_total_final_height = 0
        children.each do |child|
          p_height = child_preferred_heights[child]
          grow = child.style[:flex_grow].to_f || 0.0
          if grow > 0 && height_per_grow_unit > 0
            p_height += (height_per_grow_unit * grow).floor
          end
          provisional_total_final_height += [p_height, 0].max # Use provisional height
        end

        remaining_height = [available_height - provisional_total_final_height, 0].max
        initial_offset_y = 0
        spacing_between_y = 0
        num_children = children.size

        case justify_content
        when :flex_end
          initial_offset_y = remaining_height
        when :center
          initial_offset_y = remaining_height / 2
        when :"space-between"
          spacing_between_y = remaining_height / (num_children - 1) if num_children > 1
          # First item at start (initial_offset_y = 0)
        when :"space-around"
          if num_children > 0
            spacing_unit = remaining_height.to_f / num_children
            initial_offset_y = (spacing_unit / 2).round
            spacing_between_y = spacing_unit.round
          end
        when :"space-evenly"
          if num_children > 0
            spacing_unit = remaining_height.to_f / (num_children + 1)
            initial_offset_y = spacing_unit.round
            spacing_between_y = spacing_unit.round
          end
        # else :flex-start: initial_offset_y = 0, spacing_between_y = 0
        end

        # --- Pass 2: Position & Set Final Layout --- 
        current_y = content_y + initial_offset_y # Apply justify-content offset

        children.each do |child|
          preferred_height = child_preferred_heights[child]
          final_height = preferred_height

          grow_factor = child.style[:flex_grow].to_f || 0.0
          if grow_factor > 0 && height_per_grow_unit > 0
            added_height = (height_per_grow_unit * grow_factor).floor
            final_height += added_height
          end

          # Ensure height doesn't exceed available space (especially relevant for the last grow item)
          remaining_available = available_height - (current_y - content_y)

          final_height = [final_height, remaining_available].min

          final_height = [final_height, 0].max # Ensure non-negative height

          # Now perform the *final* layout call for the child with its determined bounds
          final_child_layout = { x: content_x, y: current_y, width: available_width, height: final_height }

          layout_node(child, final_child_layout)

          # Update child layout again to ensure position/size is exactly what we calculated here
          # (layout_node might have slightly altered it if child size exceeded final_height)
          child.layout[:x] = content_x
          child.layout[:y] = current_y
          child.layout[:width] = [child.layout[:width], available_width].min # Respect parent width constraint
          child.layout[:height] = final_height

          current_y += final_height
          current_y += spacing_between_y # Add spacing for space-* modes
        end
      else
        # No children or not column layout, do nothing in this step
      end
      
      # --- 4. Determine Final Size of this Element based on Children ---
      calculated_width = 0
      calculated_height = 0

      if element.is_a?(Beautty::Text)
         # Text size is based on content
         calculated_width = element.content.length
         calculated_height = 1
      elsif !children.empty?
        # Calculate size based on children's layout
        if flex_direction == :row
            # Width is sum of children widths, Height is max child height
            calculated_content_width = children.sum { |c| c.layout[:width] } 
            calculated_content_height = children.map { |c| c.layout[:height] }.max || 0
            # Add border back to content size
            calculated_width = calculated_content_width + (border_size * 2)
            calculated_height = calculated_content_height + (border_size * 2)
        else # Column
            # Width is max child width, Height is sum of children heights
            calculated_content_width = children.map { |c| c.layout[:width] }.max || 0
            calculated_content_height = children.sum { |c| c.layout[:height] } 
            # Add border back to content size
            calculated_width = calculated_content_width + (border_size * 2)
            calculated_height = calculated_content_height + (border_size * 2)
        end
      else
        # No children, no text -> size is just the border (if any)
        calculated_width = border_size * 2
        calculated_height = border_size * 2
      end

      # --- 5. Apply Size Constraints (Min/Max/Explicit - simplified) ---
      # Ensure calculated size doesn't exceed available space from parent
      # (Except for the root container which defines the screen bounds)
      if element.is_a?(Beautty::Container) && parent_layout[:width] == Terminal.cols && parent_layout[:height] == Terminal.rows
        calculated_width = Terminal.cols
        calculated_height = Terminal.rows
      else
        calculated_width = [calculated_width, parent_available_width].min
        calculated_height = [calculated_height, parent_available_height].min
      end

      # --- 6. Set Final Layout ---
      element.layout = { 
        x: my_x, 
        y: my_y, 
        width: calculated_width, 
        height: calculated_height 
      }
    end

    # Lays out children horizontally, implementing flex-grow.
    # @param available_height [Integer] Available height for children (cross-axis constraint)
    # @param align_items [Symbol] Cross-axis alignment (:stretch, :flex_start, etc.)
    # @param justify_content [Symbol] Main-axis alignment (:flex-start, :center, etc.)
    def layout_children_row(children, start_x, start_y, available_width, available_height, align_items, justify_content)
      return if children.empty?

      # --- Pass 1: Measure Preferred Width & Sum Grow Factors ---
      total_preferred_width = 0
      total_grow = 0.0
      child_preferred_widths = {}

      children.each do |child|
        # Estimate preferred size with unconstrained width *and* height for truer measurement
        temp_parent_layout = { x: start_x, y: start_y, width: Float::INFINITY, height: Float::INFINITY }
        layout_node(child, temp_parent_layout)
        preferred_width = child.layout[:width]
        child_preferred_widths[child] = preferred_width
        total_preferred_width += preferred_width

        grow_factor = child.style[:flex_grow].to_f || 0.0
        if grow_factor > 0
          total_grow += grow_factor
        end
      end

      # --- Calculate Distribution ---
      extra_width = available_width - total_preferred_width
      width_per_grow_unit = (total_grow > 0 && extra_width > 0) ? (extra_width / total_grow) : 0

      # --- Pass 2: Calculate Final Widths and Total Used Width ---
      child_final_widths = {}
      total_final_width = 0
      children.each do |child|
        preferred_width = child_preferred_widths[child]
        final_width = preferred_width

        grow_factor = child.style[:flex_grow].to_f || 0.0
        if grow_factor > 0 && width_per_grow_unit > 0
          added_width = (width_per_grow_unit * grow_factor).floor
          final_width += added_width
        end

        final_width = [final_width, 0].max

        child_final_widths[child] = final_width
        total_final_width += final_width
      end

      # --- Calculate Justify Content Offset --- 
      remaining_width = available_width - total_final_width
      initial_offset_x = 0
      spacing_between_x = 0
      num_children = children.size

      case justify_content
      when :flex_end
        initial_offset_x = remaining_width
      when :center
        initial_offset_x = remaining_width / 2
      when :"space-between"
        spacing_between_x = remaining_width / (num_children - 1) if num_children > 1
      when :"space-around"
        if num_children > 0
          spacing_unit = remaining_width.to_f / num_children
          initial_offset_x = (spacing_unit / 2).round
          spacing_between_x = spacing_unit.round
        end
      when :"space-evenly"
        if num_children > 0
          spacing_unit = remaining_width.to_f / (num_children + 1)
          initial_offset_x = spacing_unit.round
          spacing_between_x = spacing_unit.round
        end
      # else :flex-start: initial_offset_x = 0, spacing_between_x = 0
      end

      # --- Pass 3: Position & Set Final Layout ---
      current_x = start_x + initial_offset_x # Apply justify-content offset
      children.each do |child|
        final_width = child_final_widths[child]

        # Perform final layout call with calculated width and parent's available height
        final_child_layout = { x: current_x, y: start_y, width: final_width, height: available_height }
        layout_node(child, final_child_layout)

        # Update child layout to ensure position/size is exactly what we calculated
        child.layout[:x] = current_x
        child.layout[:y] = start_y
        child.layout[:width] = final_width

        # Handle align-items
        if align_items == :stretch && available_height != Float::INFINITY
          # Force child height to fill the row's available height (which is constrained by parent)
          child.layout[:height] = available_height
        else
          # For other align-items, use child's calculated height, constrained by available space.
          # TODO: Implement actual positioning for :flex-start, :center, :flex-end
          child.layout[:height] = [child.layout[:height], available_height].min
        end

        current_x += final_width
        current_x += spacing_between_x # Add spacing for space-* modes
      end
    end

    # (Method removed, logic integrated into layout_node)
    # def layout_children_column(children, start_x, start_y, available_width, available_height)
    #   ...
    # end

  end
end 