#!/usr/bin/env ruby

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'beautty'

# Create the application
app = Beautty.application

# Create a simple box with text
root = Beautty::Components::Box.new(
  style: {
    width: app.terminal.width,
    height: app.terminal.height,
    bg: :blue,
    border: true,
    padding: 2
  }
)

# Add a title
title = Beautty::Components::Text.new(
  "TUI Framework Demo",
  style: {
    fg: :white,
    style: :bold
  }
)
root.add_child(title)

# Add some instructions
instructions = Beautty::Components::Text.new(
  "Press any key to see it below, 'q' to quit",
  style: {
    fg: :white,
    margin: [1, 0, 0, 0]
  }
)
root.add_child(instructions)

# Add a box for displaying pressed keys
key_box = Beautty::Components::Box.new(
  style: {
    width: 30,
    height: 3,
    margin: [2, 0, 0, 0],
    border: true,
    bg: :cyan
  }
)
key_text = Beautty::Components::Text.new(
  "No key pressed yet",
  style: {
    fg: :black
  }
)
key_box.add_child(key_text)
root.add_child(key_box)

# Set the root component
app.set_root(root)

# Start the application
app.start do |canvas, input|
  if input
    key_display = input == " " ? "SPACE" : input
    key_text.text = "Key: #{key_display}"
  end
  
  exit if input == 'q'
end 