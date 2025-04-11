# Beautty - Terminal User Interface Framework

> ⚠️ **WARNING: PRE-ALPHA SOFTWARE** ⚠️
>
> This project is currently in **pre-pre-pre-alpha** stage. The API is unstable and subject to breaking changes. Don't use it it's broken. Documentation is incomplete.

A Ruby Terminal User Interface framework with a canvas-based drawing system and flexbox-like styling. Beautty provides a powerful and intuitive way to create rich terminal applications with a focus on ease of use and visual appeal. You can check the project's progress and planned features in the [TASKS.md](TASKS.md) file.

## Features

- Full-terminal canvas with double buffering
- Terminal interaction (raw mode, cursor positioning, etc.)
- Drawing primitives (text, lines, rectangles)
- Color and style support
- Resize handling
- Flexbox-like layout system
- Event-driven architecture
- Cross-platform support

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'beautty'
```

And then execute:

```bash
$ bundle install
$ gem install beautty
```

## Quick Start

```ruby
require 'beautty'

app = Beautty.application do
  # Application setup here
end

app.start do |canvas, input|
  # Draw on the canvas
  canvas.clear
  canvas.draw_text(10, 5, "Hello, World!", fg: :green, style: :bold)
  canvas.draw_rect(5, 3, 20, 5)
  
  # Handle input
  break if input == 'q'
end
```

## Basic Drawing Operations

### Text
```ruby
# Draw text with styling
canvas.draw_text(x, y, "Text", fg: :red, bg: :blue, style: :bold)
```

### Lines
```ruby
# Draw horizontal and vertical lines
canvas.draw_hline(x, y, length, char: '-', fg: :yellow)
canvas.draw_vline(x, y, length, char: '|', fg: :cyan)
```

### Rectangles
```ruby
# Draw rectangles (filled and unfilled)
canvas.draw_rect(x, y, width, height, fill: false, fg: :green)
canvas.draw_rect(x, y, width, height, fill: true, bg: :magenta)
```

## Advanced Features

### Colors
Beautty supports a wide range of colors:
- Basic colors: `:black`, `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan`, `:white`
- Bright colors: `:bright_black`, `:bright_red`, etc.
- RGB colors: `[r, g, b]` where r, g, b are values between 0-255

### Styles
Available text styles:
- `:bold`
- `:dim`
- `:italic`
- `:underline`
- `:blink`
- `:reverse`
- `:hidden`

## Development

### Running Tests
```bash
$ bundle exec rspec
```

### Documentation
```bash
$ bundle exec yard doc
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Acknowledgments

- Inspired by modern UI frameworks
- Built with Ruby's powerful terminal capabilities