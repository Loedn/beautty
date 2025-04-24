# frozen_string_literal: true

# Basic example demonstrating the Application and Container classes using raw terminal handling.
# Shows a bordered container, handles resize, displays last key pressed,
# and quits on 'q' or Ctrl+C.
#
# Run this from the root of the gem directory using:
# ruby -Ilib examples/basic_container.rb

require 'beautty'

# Include DSL methods into the main script context
include Beautty::DSLBuilder

# --- Define UI Structure using DSL ---
# Create the root container (Application still creates this)
container = Beautty::Container.new

# Build the UI tree within the container context
Beautty::DSLBuilder.build(container) do
  row do
    div(style: { border: :single, header: "row 1"}) do
      text("hello world 1")
    end
    div(style: { border: :single, header: "row 1"}) do
      text("hello world 2")
    end
    div(style: { border: :single, header: "row 1"}) do
      text("hello world 3")
    end
  end
  row style: {justify_content: :"space-between"} do
    div(style: { border: :single, header: "row 2"}) do
      text("hello world 1")
    end
    div(style: { border: :single, header: "row 2"}) do
      text("hello world 2")
    end
  end
  row style: {justify_content: :center} do
    div(style: { border: :single, header: "row 3"}) do
        div(style: { border: :single, header: "boom"}) do
            text("hello world 1")
        end
    end
  end
  row style: {justify_content: :"space-around"} do
    div(style: { border: :single, header: "row 4"}) do
      text("hello world 1")
    end
    div(style: { border: :single, header: "row 4"}) do
      text("hello world 2")
    end
  end
  row style: {justify_content: :"space-evenly"} do
    div(style: { border: :single, header: "row 5"}) do
      text("hello world 1")
    end
    div(style: { border: :single, header: "row 5"}) do
      text("hello world 2")
    end
    div(style: { border: :single, header: "row 5"}) do
      text("hello world 3")
    end
  end
end

# --- Application Setup ---
# Create the application instance with the pre-built container
app = Beautty::Application.new(container)

# --- Run Application ---
# This will take over the terminal until 'q' is pressed
app.run

# This line will be printed after the application exits and terminal is restored
puts "Application finished." 