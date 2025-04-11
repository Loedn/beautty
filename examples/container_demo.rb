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
    bg: :black,
    padding: 0
  }
)

# Add debugging information at the top
debug_box = Beautty::Components::Box.new(
  style: {
    height: 3,
    width: [app.terminal.width - 2, 60].min,
    border: true,
    border_style: :rounded,
    border_color: :red,
    bg: :black,
    margin: [0, 0, 1, 0]
  }
)
debug_box.add_child(
  Beautty::Components::Text.new(
    "Terminal size: #{app.terminal.width}x#{app.terminal.height}",
    style: {
      fg: :white,
      style: :bold
    }
  )
)
root.add_child(debug_box)

# Add a header
header = Beautty::Components::Box.new(
  header: "Container Demo",
  style: {
    height: 3,
    width: [app.terminal.width - 2, 60].min,
    border: true,
    border_style: :rounded,
    border_color: :blue,
    bg: :black
  }
)
header.add_child(
  Beautty::Components::Text.new(
    "This demo showcases the Container component",
    style: {
      fg: :white,
      style: :bold
    }
  )
)
root.add_child(header)

# Create a main content area
content = Beautty::Components::Container.column(
  style: {
    flex_grow: 1,
    margin: [1, 0, 0, 0]
  }
)
root.add_child(content)

# Row container example - with explicit width constraint
row_container = Beautty::Components::Container.row(
  border: true,
  border_style: :rounded,
  border_color: :blue,
  bg: :black,
  padding: 1,
  margin: [0, 0, 1, 0],
  style: {
    width: [app.terminal.width - 4, 60].min
  }
)

# Add some items to the row container
colors = [:red, :green, :yellow, :magenta, :cyan]
colors.each do |color|
  box = Beautty::Components::Box.new(
    style: {
      width: 8,
      height: 3,
      margin: [0, 1, 0, 0],
      border: true,
      border_style: :rounded,
      border_color: color,
      bg: :black
    }
  )
  box.add_child(
    Beautty::Components::Text.new(
      color.to_s,
      style: {
        fg: :white,
        padding: [1, 0, 0, 1]
      }
    )
  )
  row_container.add_flex_child(box, flex_grow: 1)
end

content.add_child(row_container)

# Column container example
column_container = Beautty::Components::Container.column(
  border: true,
  border_style: :rounded,
  border_color: :blue,
  bg: :black,
  padding: 1,
  margin: [0, 0, 1, 0],
  style: {
    width: [app.terminal.width - 4, 60].min
  }
)

# Add some items to the column container
3.times do |i|
  box = Beautty::Components::Box.new(
    header: "Item #{i+1}",
    style: {
      height: 3,
      margin: [0, 0, 1, 0],
      border: true,
      border_style: :rounded,
      border_color: :green,
      bg: :black
    }
  )
  column_container.add_flex_child(box, flex_grow: 1)
end

content.add_child(column_container)

# Centered container example
centered_container = Beautty::Components::Container.centered(
  border: true,
  border_style: :rounded,
  border_color: :blue,
  bg: :black,
  padding: 1,
  height: 10,
  style: {
    width: [app.terminal.width - 4, 60].min
  }
)

centered_box = Beautty::Components::Box.new(
  header: "Centered",
  style: {
    width: 20,
    height: 5,
    border: true,
    border_style: :rounded,
    border_color: :magenta,
    bg: :black
  }
)
centered_box.add_child(
  Beautty::Components::Text.new(
    "This box is centered",
    style: {
      fg: :white,
      padding: [1, 0, 0, 1]
    }
  )
)
centered_container.add_child(centered_box)

content.add_child(centered_container)

# Add a footer with commands
footer = Beautty::Components::Footer.new(
  commands: {
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
  end
end 