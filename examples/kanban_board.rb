#!/usr/bin/env ruby

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'beautty'

# Create the application
app = Beautty.application

# Sample data for the Kanban board
todo_tasks = [
  "Implement terminal detection",
  "Create canvas system",
  "Add color support",
  "Design component API"
]

in_progress_tasks = [
  "Implement flexbox layout",
  "Create text component"
]

done_tasks = [
  "Project setup",
  "Create repository",
  "Write initial specs"
]

# Track the currently selected task and column
selected_column = 0
selected_task = 0

# Helper to get the current column's tasks
def current_tasks(selected_column, todo_tasks, in_progress_tasks, done_tasks)
  case selected_column
  when 0 then todo_tasks
  when 1 then in_progress_tasks
  when 2 then done_tasks
  end
end

# Create the root component
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
    "Kanban Board Demo",
    style: {
      fg: :white,
      style: :bold
    }
  )
)
root.add_child(header)

# Create the main content area with columns
main = Beautty::Components::Box.new(
  style: {
    flex_grow: 1,
    display: :flex,
    flex_direction: :row,
    padding: 1
  }
)
root.add_child(main)

# Create the three columns
columns = []
column_titles = ["To Do", "In Progress", "Done"]
column_colors = [:cyan, :yellow, :green]

# Calculate column width based on terminal width
column_width = (app.terminal.width - 10) / 3  # Subtract some padding and divide by 3

column_titles.each_with_index do |title, index|
  column = Beautty::Components::Box.new(
    style: {
      width: column_width,  # Set explicit width
      border: true,
      margin: [0, 1, 0, 1],
      display: :flex,
      flex_direction: :column
    }
  )
  
  # Column header
  column_header = Beautty::Components::Box.new(
    style: {
      height: 3,
      bg: column_colors[index],
      border: true
    }
  )
  column_header.add_child(
    Beautty::Components::Text.new(
      title,
      style: {
        fg: :black,
        style: :bold,
        padding: [1, 0, 0, 0]  # Add top padding to center vertically
      }
    )
  )
  column.add_child(column_header)
  
  # Task container
  task_container = Beautty::Components::Box.new(
    style: {
      flex_grow: 1,
      padding: 1,
      display: :flex,
      flex_direction: :column,
      bg: :black,
      fg: :white
    }
  )
  
  # Add tasks to the column
  tasks = case index
          when 0 then todo_tasks
          when 1 then in_progress_tasks
          when 2 then done_tasks
          end
  
  tasks.each_with_index do |task_text, task_index|
    is_selected = (selected_column == index && selected_task == task_index)
    
    task = Beautty::Components::Box.new(
      style: {
        height: 3,
        margin: [0, 0, 1, 0],
        border: true,
        bg: is_selected ? :bright_black : nil
      }
    )
    task.add_child(
      Beautty::Components::Text.new(
        task_text.length > column_width - 6 ? task_text[0...(column_width - 9)] + "..." : task_text,
        style: {
          fg: :bright_white,
          style: is_selected ? :bold : nil,
          padding: [1, 0, 0, 2]  # Add top and left padding
        }
      )
    )
    task_container.add_child(task)
  end
  
  column.add_child(task_container)
  main.add_child(column)
  columns << column
end

# Add a footer with instructions
footer = Beautty::Components::Box.new(
  style: {
    height: 5,
    bg: :blue,
    border: true,
    padding: 1
  }
)

instructions = Beautty::Components::Text.new(
  "Controls: Arrow keys to navigate, Space to select a task, Enter to move task, q to quit",
  style: {
    fg: :white
  }
)
footer.add_child(instructions)

# Status message for user feedback
status_message = Beautty::Components::Text.new(
  "",
  style: {
    fg: :white,
    margin: [1, 0, 0, 0]
  }
)
footer.add_child(status_message)

root.add_child(footer)

# Set the root component
app.set_root(root)

# Track if a task is currently selected for moving
task_selected_for_move = false

# Start the application
app.start do |canvas, input|
  if input
    case input
    when 'q'
      exit
    when "\e[A" # Up arrow
      if selected_task > 0
        selected_task -= 1
        status_message.text = "Moved up"
      end
    when "\e[B" # Down arrow
      current_column_tasks = current_tasks(selected_column, todo_tasks, in_progress_tasks, done_tasks)
      if selected_task < current_column_tasks.length - 1
        selected_task += 1
        status_message.text = "Moved down"
      end
    when "\e[C" # Right arrow
      if selected_column < 2
        old_column_tasks = current_tasks(selected_column, todo_tasks, in_progress_tasks, done_tasks)
        selected_column += 1
        new_column_tasks = current_tasks(selected_column, todo_tasks, in_progress_tasks, done_tasks)
        selected_task = [selected_task, new_column_tasks.length - 1].min
        status_message.text = "Moved to next column"
      end
    when "\e[D" # Left arrow
      if selected_column > 0
        old_column_tasks = current_tasks(selected_column, todo_tasks, in_progress_tasks, done_tasks)
        selected_column -= 1
        new_column_tasks = current_tasks(selected_column, todo_tasks, in_progress_tasks, done_tasks)
        selected_task = [selected_task, new_column_tasks.length - 1].min
        status_message.text = "Moved to previous column"
      end
    when ' ' # Space
      if task_selected_for_move
        task_selected_for_move = false
        status_message.text = "Task unselected"
      else
        task_selected_for_move = true
        status_message.text = "Task selected for move. Press Enter to move to current column."
      end
    when "\r" # Enter
      if task_selected_for_move
        # Get the task from the original column
        source_tasks = case selected_column
                       when 0 then todo_tasks
                       when 1 then in_progress_tasks
                       when 2 then done_tasks
                       end
        
        task_to_move = source_tasks[selected_task]
        
        # Move the task to the target column
        target_column = selected_column
        
        # Remove from source
        source_tasks.delete_at(selected_task)
        
        # Add to target
        case target_column
        when 0 then todo_tasks << task_to_move
        when 1 then in_progress_tasks << task_to_move
        when 2 then done_tasks << task_to_move
        end
        
        task_selected_for_move = false
        status_message.text = "Task moved to #{column_titles[target_column]}"
        
        # Adjust selected task if needed
        current_column_tasks = current_tasks(selected_column, todo_tasks, in_progress_tasks, done_tasks)
        selected_task = [selected_task, current_column_tasks.length - 1].min
      end
    end
    
    # Update the UI to reflect the current state
    # Clear existing tasks
    columns.each_with_index do |column, col_index|
      # Get the task container (second child of the column)
      task_container = column.children[1]
      task_container.children.clear
      
      # Get the tasks for this column
      tasks = case col_index
              when 0 then todo_tasks
              when 1 then in_progress_tasks
              when 2 then done_tasks
              end
      
      # Add tasks to the column
      tasks.each_with_index do |task_text, task_index|
        is_selected = (selected_column == col_index && selected_task == task_index)
        is_moving = is_selected && task_selected_for_move
        
        task = Beautty::Components::Box.new(
          style: {
            height: 3,
            margin: [0, 0, 1, 0],
            border: true,
            bg: is_selected ? (is_moving ? :bright_cyan : :bright_black) : nil
          }
        )
        task.add_child(
          Beautty::Components::Text.new(
            task_text.length > column_width - 6 ? task_text[0...(column_width - 9)] + "..." : task_text,
            style: {
              fg: is_moving ? :black : :bright_white,
              style: is_moving ? :bold : nil,
              padding: [1, 0, 0, 2]  # Add top and left padding
            }
          )
        )
        task_container.add_child(task)
      end
    end
    
    # Force a re-render of the component tree
    root.calculate_layout(app.terminal.width, app.terminal.height)
  end
end 