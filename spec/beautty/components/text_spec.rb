require 'spec_helper'

RSpec.describe Beautty::Components::Text do
  let(:text) { described_class.new("Hello") }
  
  describe '#initialize' do
    it 'creates a text component with the given text' do
      expect(text).to be_a(Beautty::Component)
      expect(text.text).to eq("Hello")
    end
    
    it 'accepts style options' do
      text = described_class.new("Hello", style: { fg: :red, style: :bold })
      
      expect(text.style.fg).to eq(:red)
      expect(text.style.style).to eq(:bold)
    end
  end
  
  describe '#calculate_content_size' do
    it 'uses text length for width if not specified' do
      text.calculate_layout(100, 50)
      
      expect(text.content_width).to eq(5) # "Hello" length
      expect(text.content_height).to eq(1) # Single line
    end
    
    it 'respects explicit width and height' do
      text.style = Beautty::Style.new(width: 20, height: 3)
      
      text.calculate_layout(100, 50)
      
      expect(text.content_width).to eq(20)
      expect(text.content_height).to eq(3)
    end
  end
  
  describe '#render' do
    let(:canvas) { instance_double(Beautty::Canvas) }
    
    before do
      allow(canvas).to receive(:draw_rect)
      allow(canvas).to receive(:draw_text)
    end
    
    it 'draws the text with proper positioning and styling' do
      text.style = Beautty::Style.new(
        fg: :red,
        bg: :blue,
        style: :bold,
        padding: { top: 2, left: 3 },
        border: true
      )
      
      text.x = 10
      text.y = 20
      text.computed_style = text.style
      
      text.render(canvas)
      
      # Text should be positioned at:
      # x = 10 (component x) + 3 (padding left) + 1 (border) = 14
      # y = 20 (component y) + 2 (padding top) + 1 (border) = 23
      expect(canvas).to have_received(:draw_text).with(
        14, 23, "Hello", fg: :red, bg: :blue, style: :bold
      )
    end
  end
end 