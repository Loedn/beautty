require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Generate documentation'
task :doc do
  sh 'yard doc'
end

desc 'Run the hello world example'
task :hello do
  ruby 'examples/hello_world.rb'
end

desc 'Run the Beautty framework with a simple demo'
task :demo do
  $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
  require 'beautty'
  
  app = Beautty.application
  
  # Create a root component
  root = Beautty::Components::Box.new(
    style: {
      width: app.terminal.width,
      height: app.terminal.height,
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
      "TUI Framework Quick Demo",
      style: {
        fg: :white,
        style: :bold
      }
    )
  )
  root.add_child(header)
  
  # Add instructions
  instructions = Beautty::Components::Text.new(
    "Press any key to see it here:",
    style: {
      fg: :green,
      margin: [2, 0, 0, 0]
    }
  )
  root.add_child(instructions)
  
  # Add key display box
  key_box = Beautty::Components::Box.new(
    style: {
      width: 30,
      height: 3,
      margin: [1, 0, 0, 0],
      border: true
    }
  )
  key_text = Beautty::Components::Text.new(
    "No key pressed yet",
    style: {
      fg: :bright_cyan
    }
  )
  key_box.add_child(key_text)
  root.add_child(key_box)
  
  # Add quit instructions
  quit_text = Beautty::Components::Text.new(
    "Press 'q' to quit",
    style: {
      fg: :yellow,
      margin: [2, 0, 0, 0]
    }
  )
  root.add_child(quit_text)
  
  # Set the root component
  app.set_root(root)
  
  # Start the application
  app.start do |canvas, input|
    if input
      key_display = input == " " ? "SPACE" : input
      key_text.text = "Key: #{key_display}"
      
      # Force a re-render of the component tree
      root.calculate_layout(app.terminal.width, app.terminal.height)
    end
    
    exit if input == 'q'
  end
end

desc 'Run the flexbox demo'
task :flexbox do
  ruby 'examples/flexbox_demo.rb'
end

desc 'Run the simple demo'
task :simple do
  ruby 'examples/simple_demo.rb'
end

desc 'Run the Kanban board demo'
task :kanban do
  ruby 'examples/kanban_board.rb'
end

desc 'Run the components demo'
task :components do
  ruby 'examples/components_demo.rb'
end

desc 'Run the navigation demo'
task :navigation do
  ruby 'examples/navigation_demo.rb'
end

desc 'Run the dumb demo'
task :dumb do
  ruby 'examples/dumb_demo.rb'
end

desc 'Run the container demo'
task :container do
  ruby 'examples/container_demo.rb'
end
