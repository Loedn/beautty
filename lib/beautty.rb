# frozen_string_literal: true

require_relative "beautty/version"
require_relative "beautty/terminal"
require_relative "beautty/element"
require_relative "beautty/row"
require_relative "beautty/text"
require_relative "beautty/div"
require_relative "beautty/dsl_builder"
require_relative "beautty/layout_engine"
require_relative "beautty/container"
require_relative "beautty/application"

module Beautty
  class Error < StandardError; end
  # Your code goes here...
end 