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

# Add a header box with a border header
header_box = Beautty::Components::Box.new(
  header: "Component Demo",
  style: {
    height: 5,
    border: true,
    bg: :blue,
    padding: 1
  }
)
header_box.add_child(
  Beautty::Components::Text.new(
    "This demonstrates the new components in Phase 3",
    style: {
      fg: :white,
      style: :bold
    }
  )
)
root.add_child(header_box)

# Add a content area
content = Beautty::Components::Box.new(
  style: {
    flex_grow: 1,
    display: :flex,
    flex_direction: :row,
    padding: 1
  }
)
root.add_child(content)

# Update the boxes to use different border styles
box_colors = [:red, :green, :blue, :magenta, :cyan]
box_titles = ["Single Border", "Double Border", "Thick Border", "Rounded Border", "Custom Border"]
border_styles = [:single, :double, :thick, :rounded, :single]

box_colors.each_with_index do |color, index|
  box = Beautty::Components::Box.new(
    header: box_titles[index],
    style: {
      flex_grow: 1,
      border: true,
      border_style: border_styles[index],
      border_radius: index == 3 || index == 4, # Rounded corners for the last two
      border_thickness: index == 4 ? 2 : 1,    # Thicker border for the last one
      margin: 1,
      bg: color,
      padding: 1
    }
  )
  box.add_child(
    Beautty::Components::Text.new(
      "This box has a #{border_styles[index]} border style",
      style: {
        fg: :white,
        padding: [1, 0, 0, 0]
      }
    )
  )
  content.add_child(box)
end

# Add a footer with commands
footer = Beautty::Components::Footer.new(
  commands: {
    'q' => 'Quit',
    'h' => 'Help',
    'r' => 'Refresh',
    's' => 'Save'
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
  when 'h'
    footer.add_command('b', 'Back')
    status_message = "Help: This is a demo of the new components in Phase 3"
  when 'b'
    footer.remove_command('b')
    status_message = nil
  end
  
  # Force a re-render of the component tree
  root.calculate_layout(app.terminal.width, app.terminal.height)
end 