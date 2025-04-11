#!/usr/bin/env ruby

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'beautty'

# Create the application
app = Beautty.application

# Create a root container with flex layout
root = Beautty::Components::Box.new(
  style: {
    width: app.terminal.width,
    height: app.terminal.height,
    display: :flex,
    flex_direction: :column,
    bg: :black
  }
)

# Add a header
header = Beautty::Components::Box.new(
  style: {
    height: 3,
    bg: :blue,
    border: true
  }
)
header.add_child(
  Beautty::Components::Text.new(
    "Flexbox Demo",
    style: {
      fg: :white,
      style: :bold
    }
  )
)
root.add_child(header)

# Create a main content area with row layout
main = Beautty::Components::Box.new(
  style: {
    flex_grow: 1,
    display: :flex,
    flex_direction: :row
  }
)
root.add_child(main)

# Left sidebar
sidebar = Beautty::Components::Box.new(
  style: {
    width: 20,
    bg: :cyan,
    border: true,
    padding: 1
  }
)
sidebar.add_child(
  Beautty::Components::Text.new(
    "Sidebar",
    style: {
      fg: :black,
      style: :bold
    }
  )
)
sidebar.add_child(
  Beautty::Components::Text.new(
    "Menu Item 1",
    style: {
      fg: :black
    }
  )
)
sidebar.add_child(
  Beautty::Components::Text.new(
    "Menu Item 2",
    style: {
      fg: :black
    }
  )
)
sidebar.add_child(
  Beautty::Components::Text.new(
    "Menu Item 3",
    style: {
      fg: :black
    }
  )
)
main.add_child(sidebar)

# Content area
content = Beautty::Components::Box.new(
  style: {
    flex_grow: 1,
    border: true,
    padding: 2,
    bg: :white
  }
)
content.add_child(
  Beautty::Components::Text.new(
    "Main Content Area",
    style: {
      fg: :black,
      style: :bold
    }
  )
)
content.add_child(
  Beautty::Components::Text.new(
    "This is a demonstration of the flexbox-like layout system.",
    style: {
      fg: :black
    }
  )
)
content.add_child(
  Beautty::Components::Text.new(
    "Try resizing the terminal to see how the layout adapts!",
    style: {
      fg: :black
    }
  )
)

# Create a row of boxes to demonstrate flex-grow
row = Beautty::Components::Box.new(
  style: {
    display: :flex,
    flex_direction: :row,
    height: 5,
    margin: [2, 0, 0, 0]
  }
)

# Add boxes with different flex-grow values
colors = [:red, :green, :blue, :magenta, :yellow]
(1..5).each do |i|
  box = Beautty::Components::Box.new(
    style: {
      flex_grow: i,
      bg: colors[i-1],
      border: true
    }
  )
  box.add_child(
    Beautty::Components::Text.new(
      "flex: #{i}",
      style: {
        fg: :white,
        style: :bold
      }
    )
  )
  row.add_child(box)
end

content.add_child(row)
main.add_child(content)

# Footer
footer = Beautty::Components::Box.new(
  style: {
    height: 3,
    bg: :blue,
    border: true
  }
)
footer.add_child(
  Beautty::Components::Text.new(
    "Press 'q' to quit",
    style: {
      fg: :white
    }
  )
)
root.add_child(footer)

# Set the root component
app.set_root(root)

# Start the application
app.start do |canvas, input|
  exit if input == 'q'
end 