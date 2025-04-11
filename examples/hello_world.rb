#!/usr/bin/env ruby

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'beautty'

app = Beautty.application

app.start do |canvas, input = nil|
  # Clear the canvas
  canvas.clear
  
  # Draw a border around the screen
  canvas.draw_rect(0, 0, canvas.width, canvas.height)
  
  # Draw a title
  title = "TUI Framework Demo"
  x = (canvas.width - title.length) / 2
  canvas.draw_text(x, 1, title, fg: :bright_white, style: :bold)
  
  # Draw some styled text
  canvas.draw_text(2, 3, "Welcome to the TUI Framework!", fg: :green)
  canvas.draw_text(2, 5, "Press any key to see it echoed below", fg: :yellow)
  canvas.draw_text(2, 6, "Press 'q' to quit", fg: :yellow)
  
  # Draw a box for the input display
  canvas.draw_rect(2, 8, 30, 3)
  
  # Show the last pressed key
  if input
    key_display = input == " " ? "SPACE" : input
    canvas.draw_text(4, 9, "Last key: #{key_display}", fg: :bright_cyan)
  end
  
  # Draw a color palette
  colors = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white]
  
  canvas.draw_text(2, 13, "Color Palette:", fg: :bright_white)
  
  colors.each_with_index do |color, i|
    # Normal colors
    canvas.draw_rect(2 + i*5, 15, 4, 2, fill: true, bg: color)
    
    # Bright colors
    bright_color = "bright_#{color}".to_sym
    canvas.draw_rect(2 + i*5, 18, 4, 2, fill: true, bg: bright_color)
  end
  
  # Draw a styled text demo
  styles = [:bold, :dim, :italic, :underline, :blink, :reverse]
  
  canvas.draw_text(2, 22, "Text Styles:", fg: :bright_white)
  
  styles.each_with_index do |style, i|
    y = 24 + i
    canvas.draw_text(2, y, style.to_s, fg: :white)
    canvas.draw_text(15, y, "This is #{style} text", fg: :white, style: style)
  end
  
  # Exit on 'q' press
  exit if input == 'q'
end 