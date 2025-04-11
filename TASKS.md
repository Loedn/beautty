# Ruby TUI Framework Development Tasks


## Acceptance Criteria

- [x] The application must be able to run in a terminal
- [x] The application must be able to draw text, lines, and rectangles
- [x] The application must be able to handle input
- [x] The application must be able to resize
- [x] The application must be able to handle colors
- [ ] As a proof of concept the application should be a kanban board with a list of tasks, movable between columns
- [ ] All code must be covered by tests

## Phase 1: Foundation

- [x] Implement terminal interaction basics
  - [x] Detect terminal size
  - [x] Handle terminal resize events
  - [x] Implement cursor positioning
  - [x] Handle raw input mode

- [x] Create canvas system
  - [x] Implement a buffer for drawing
  - [x] Create methods for clearing the screen
  - [x] Implement double buffering to prevent flickering
  - [x] Add basic drawing primitives (text, lines, rectangles)

## Phase 2: Styling System

- [x] Design the styling API
  - [x] Define style properties (color, background, font styles)
  - [x] Create a style object structure

- [x] Implement flexbox-like layout system
  - [x] Create container elements
  - [x] Implement flex direction (row, column)
  - [x] Add justify content options
  - [x] Add align items options
  - [x] Implement flex grow/shrink/basis

- [x] Add style inheritance and cascading
  - [x] Allow parent styles to flow to children
  - [x] Implement style overrides

## Phase 3: UI Components

- [ ] Create basic UI components
  - [ ] Footer component (bottom of the screen) should always display the available commands
  - [ ] Navigation component that accepts tabs and renders different views (similar to the navigation in the terminal version of cursor)
  - [x] Text/Label component
  - [x] Box/Panel component
  - [ ] Border component
  - [ ] Input field component
  - [ ] Button component
  - [ ] Text input component
  - [ ] Text area component
  - [ ] List component
  - [ ] List item component
  - [ ] Checkbox component
  - [ ] Radio button component
  - [ ] Radio group component
  - [ ] Dropdown component
  - [ ] Modal component
  - [ ] Dialog component
  - [ ] Tabs component
  - [ ] Table/Grid component
  - [ ] Progress bar component

- [ ] Box component style
    - [ ] each box should have an optional header that renders on the border of the top left side of the box

- [ ] Implement component lifecycle
  - [ ] Initialize
  - [ ] Mount
  - [ ] Update
  - [ ] Unmount

- [ ] Add event system
  - [ ] Keyboard event handling
  - [ ] Mouse event handling (if terminal supports it)
  - [ ] Custom events

## Phase 4: Advanced Features

- [ ] Implement focus management
  - [ ] Tab navigation between components
  - [ ] Focus indicators
  - [ ] Focus groups

- [ ] Add theming support
  - [ ] Theme definition structure
  - [ ] Light/dark themes
  - [ ] Custom theme creation

- [ ] Create advanced components
  - [ ] Dropdown/Select component
  - [ ] Modal/Dialog component
  - [ ] Tabs component
  - [ ] Table/Grid component
  - [ ] Progress bar component

## Phase 5: Performance & Polish

- [ ] Optimize rendering
  - [ ] Only redraw changed areas
  - [ ] Implement render throttling
  - [ ] Add benchmarking tools

- [ ] Add accessibility features
  - [ ] Screen reader compatibility
  - [ ] Keyboard navigation improvements

- [ ] Create documentation
  - [ ] API documentation
  - [ ] Usage examples
  - [ ] Component gallery

## Phase 6: Distribution & Examples

- [ ] Package as a gem
  - [ ] Set up gem specification
  - [ ] Publish to RubyGems

- [ ] Create example applications
  - [ ] Simple todo application
  - [ ] Dashboard example
  - [ ] Form input example

- [ ] Add testing
  - [x] Unit tests
  - [ ] Integration tests
  - [ ] Visual regression tests
