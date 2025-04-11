#!/usr/bin/env ruby

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'beautty'

# Create the application
app = Beautty.application

# Create a root component
root = Beautty::Components::Box.new(
  style: {
    width: app.terminal.width,
    height: app.terminal.height,
    display: :flex,
    flex_direction: :column,
    bg: :black
  }
)

# Create the navigation component
navigation = Beautty::Components::Box.new(
  style: {
    height: 3,
    width: '100%',
    display: :flex,
    flex_direction: :row,
    bg: :blue,
    padding: [0, 0, 0, 0]
  }
)

# Create the logo on the left
logo = Beautty::Components::Box.new(
  style: {
    width: 15,
    height: 3,
    padding: [0, 1, 0, 1],
    bg: :blue
  }
)
logo.add_child(
  Beautty::Components::Text.new(
    "TUI Framework",
    style: {
      fg: :bright_white,
      style: :bold,
      padding: [1, 0, 0, 0]  # Center text vertically
    }
  )
)
navigation.add_child(logo)

# Create a spacer to push nav items to the right
spacer = Beautty::Components::Box.new(
  style: {
    flex_grow: 1,
    bg: :blue
  }
)
navigation.add_child(spacer)

# Create navigation items on the right
nav_items = ["About", "Docs", "Hello"]
active_item = 0

nav_items.each_with_index do |item, index|
  is_active = index == active_item
  
  nav_item = Beautty::Components::Box.new(
    style: {
      width: 8,
      height: 3,
      padding: [0, 0, 0, 0],
      bg: is_active ? :white : :blue
    }
  )
  
  # Add the nav item text
  nav_item.add_child(
    Beautty::Components::Text.new(
      item,
      style: {
        fg: is_active ? :black : :white,
        style: is_active ? :bold : nil,
        padding: [1, 0, 0, 0]  # Center text vertically
      }
    )
  )
  
  # Add underline for active item
  if is_active
    underline = Beautty::Components::Box.new(
      style: {
        height: 1,
        width: '100%',
        bg: :bright_white,
        margin: [2, 0, 0, 0]  # Position at the bottom
      }
    )
    nav_item.add_child(underline)
  end
  
  navigation.add_child(nav_item)
end

# Add the navigation to the root
root.add_child(navigation)

# Create content areas for each nav item
content_areas = []

# About content
about_content = Beautty::Components::Box.new(
  style: {
    height: app.terminal.height - 7,
    padding: 1,
    border: true,
    border_style: :rounded
  }
)
about_content.add_child(
  Beautty::Components::Text.new(
    "\nTUI Framework is a Ruby library for building\n" +
    "text-based user interfaces with a component-\n" +
    "based architecture.",
    style: {
      fg: :white,
      margin: [0, 0, 0, 0]
    }
  )
)
content_areas << about_content

# Docs content
docs_content = Beautty::Components::Box.new(
  style: {
    height: app.terminal.height - 7,
    padding: 1,
    border: true,
    border_style: :rounded
  }
)
docs_content.add_child(
  Beautty::Components::Text.new(
    "Documentation",
    style: {
      fg: :bright_white,
      style: :bold
    }
  )
)
docs_content.add_child(
  Beautty::Components::Text.new(
    "\nComponents:\n" +
    "- Box: A container component\n" +
    "- Text: A text display component\n" +
    "- Footer: A footer component\n" +
    "- Navigation: A navigation component",
    style: {
      fg: :white,
      margin: [0, 0, 0, 0]
    }
  )
)
content_areas << docs_content

# Hello content
hello_content = Beautty::Components::Box.new(
  style: {
    height: app.terminal.height - 7,
    padding: 1,
    border: true,
    border_style: :rounded
  }
)
hello_content.add_child(
  Beautty::Components::Text.new(
    "Hello World!",
    style: {
      fg: :bright_white,
      style: :bold
    }
  )
)
hello_content.add_child(
  Beautty::Components::Text.new(
    "\nWelcome to the TUI Framework demo!\n\n" +
    "This is a simple navigation bar example that mimics a website layout.",
    style: {
      fg: :white,
      margin: [0, 0, 0, 0]
    }
  )
)
content_areas << hello_content

# Add the active content area to the root
root.add_child(content_areas[active_item])

# Add a footer with commands
footer = Beautty::Components::Footer.new(
  commands: {
    'Left/Right' => 'Navigate',
    'q' => 'Quit'
  }
)
root.add_child(footer)

# Set the root component
app.set_root(root)

# Start the application
app.start do |canvas, input|
  case input
  when 'q'
    exit
  when "\e[D", 'h' # Left arrow or 'h'
    active_item = (active_item - 1) % nav_items.length
    # Rebuild the UI
    root.children.clear
    root.add_child(navigation)
    root.add_child(content_areas[active_item])
    root.add_child(footer)
  when "\e[C", 'l' # Right arrow or 'l'
    active_item = (active_item + 1) % nav_items.length
    # Rebuild the UI
    root.children.clear
    root.add_child(navigation)
    root.add_child(content_areas[active_item])
    root.add_child(footer)
  end
  
  # Force a re-render of the component tree
  root.calculate_layout(app.terminal.width, app.terminal.height)
end 