# frozen_string_literal: true

module Beautty
  # Provides helper methods for the UI definition DSL.
  module DSLBuilder
    # Stores the current parent element during block execution.
    # NOTE: This simple approach is NOT thread-safe.
    # A more robust solution might use Thread.current or pass context explicitly.
    @@current_parent = nil

    def self.build(root, &block)
      original_parent = @@current_parent
      @@current_parent = root
      block.call(root) # Pass root element to the block if needed
    ensure
      @@current_parent = original_parent
    end

    def self.current_parent
      @@current_parent
    end

    def self.within_parent(new_parent, &block)
      original_parent = @@current_parent
      @@current_parent = new_parent
      new_parent.instance_eval(&block) # Evaluate block in element's context
    ensure
      @@current_parent = original_parent
    end

    # DSL helper methods
    def div(style: {}, &block)
      element = Beautty::Div.new(style: style)
      @@current_parent&.add_child(element)
      DSLBuilder.within_parent(element, &block) if block
      element
    end

    def row(style: {}, &block)
      element = Beautty::Row.new(style: style)
      @@current_parent&.add_child(element)
      DSLBuilder.within_parent(element, &block) if block
      element
    end

    def text(content, style: {})
      element = Beautty::Text.new(content, style: style)
      @@current_parent&.add_child(element)
      element
    end

    # Add other element helpers (button, etc.) here later

  end
end 