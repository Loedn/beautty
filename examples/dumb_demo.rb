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
    padding: 2
  }
)

# Create a box with a header
hello_box = Beautty::Components::Box.new(
  header: "Hello World",
  style: {
    width: 40,
    height: 10,
    border: true,
    border_style: :rounded,
    bg: :blue,
    padding: 1
  }
)

# Add some content to the box
hello_box.add_child(
  Beautty::Components::Text.new(
    "This is a simple box component with a header.",
    style: {
      fg: :white,
      style: :bold
    }
  )
)

hello_box.add_child(
  Beautty::Components::Text.new(
    "\nPress 'q' to quit.",
    style: {
      fg: :bright_yellow,
      margin: [1, 0, 0, 0]
    }
  )
)

# Add the hello box to the root
root.add_child(hello_box)

# Set the root component
app.set_root(root)

# Start the application
app.start do |canvas, input|
  case input
  when 'q'
    exit
  end
end 