module Beautty
  # Represents a style definition for UI elements
  class Style
    attr_accessor :fg, :bg, :style, :padding, :margin, :border
    attr_accessor :width, :height, :min_width, :min_height, :max_width, :max_height
    
    # Flexbox properties
    attr_accessor :display, :flex_direction, :justify_content, :align_items
    attr_accessor :flex_grow, :flex_shrink, :flex_basis
    
    # Add new border style properties
    attr_accessor :border_style, :border_thickness, :border_radius
    
    # Add border_color to the Style class
    attr_accessor :border_color
    
    def initialize(options = {})
      # Colors
      @fg = options[:fg]
      @bg = options[:bg]
      @style = options[:style]
      
      # Spacing
      @padding = parse_box_value(options[:padding] || 0)
      @margin = parse_box_value(options[:margin] || 0)
      @border = options[:border]
      
      # Sizing
      @width = options[:width]
      @height = options[:height]
      @min_width = options[:min_width] || 0
      @min_height = options[:min_height] || 0
      @max_width = options[:max_width]
      @max_height = options[:max_height]
      
      # Flexbox
      @display = options[:display] || :block
      @flex_direction = options[:flex_direction] || :row
      @justify_content = options[:justify_content] || :flex_start
      @align_items = options[:align_items] || :stretch
      @flex_grow = options[:flex_grow] || 0
      @flex_shrink = options[:flex_shrink] || 1
      @flex_basis = options[:flex_basis] || :auto
      
      # Border style (can be :single, :double, :thick, :rounded)
      @border_style = options[:border_style] || :single
      
      # Border thickness (1 or 2)
      @border_thickness = options[:border_thickness] || 1
      
      # Border radius (boolean or number 0-2)
      @border_radius = options[:border_radius] || false
      
      # Add border_color
      @border_color = options[:border_color]
    end
    
    # Merge this style with another style, with the other style taking precedence
    # @param other [Style] The style to merge with
    # @return [Style] A new style with merged properties
    def merge(other)
      return self.dup unless other.is_a?(Style)
      
      result = self.dup
      
      # Copy all properties from other if they are not nil
      other.instance_variables.each do |var|
        value = other.instance_variable_get(var)
        result.instance_variable_set(var, value) unless value.nil?
      end
      
      result.border_style = other.border_style if other.border_style
      result.border_thickness = other.border_thickness if other.border_thickness
      result.border_radius = other.border_radius if other.border_radius
      
      result
    end
    
    # Create a new style with the given overrides
    # @param overrides [Hash] The properties to override
    # @return [Style] A new style with overridden properties
    def with(overrides = {})
      self.merge(Style.new(overrides))
    end
    
    private
    
    # Parse a box value (padding or margin) into a hash with top, right, bottom, left
    # @param value [Integer, Array, Hash] The value to parse
    # @return [Hash] A hash with :top, :right, :bottom, :left keys
    def parse_box_value(value)
      case value
      when Integer
        { top: value, right: value, bottom: value, left: value }
      when Array
        if value.length == 1
          { top: value[0], right: value[0], bottom: value[0], left: value[0] }
        elsif value.length == 2
          { top: value[0], right: value[1], bottom: value[0], left: value[1] }
        elsif value.length == 3
          { top: value[0], right: value[1], bottom: value[2], left: value[1] }
        elsif value.length >= 4
          { top: value[0], right: value[1], bottom: value[2], left: value[3] }
        end
      when Hash
        {
          top: value[:top] || 0,
          right: value[:right] || 0,
          bottom: value[:bottom] || 0,
          left: value[:left] || 0
        }
      else
        { top: 0, right: 0, bottom: 0, left: 0 }
      end
    end
  end
end 