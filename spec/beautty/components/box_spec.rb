require 'spec_helper'

RSpec.describe Beautty::Components::Box do
  let(:box) { described_class.new }
  
  describe '#initialize' do
    it 'creates a box component' do
      expect(box).to be_a(Beautty::Component)
    end
    
    it 'accepts style options' do
      box = described_class.new(style: { bg: :blue, border: true })
      
      expect(box.style.bg).to eq(:blue)
      expect(box.style.border).to eq(true)
    end
  end
  
  describe '#render' do
    let(:canvas) { instance_double(Beautty::Canvas) }
    
    before do
      allow(canvas).to receive(:draw_rect)
    end
    
    it 'calls the parent render method' do
      box.computed_style = box.style
      
      # We'll verify it calls super by checking if draw_rect is called
      # when we set a background color
      box.style = Beautty::Style.new(bg: :blue)
      box.width = 100
      box.height = 50
      box.computed_style = box.style
      
      box.render(canvas)
      
      expect(canvas).to have_received(:draw_rect).with(
        0, 0, 100, 50, fill: true, bg: :blue
      )
    end
    
    it 'renders the header text on the border if present' do
      box.header = "Test Header"
      box.style = Beautty::Style.new(border: true)
      box.width = 100
      box.height = 50
      box.computed_style = box.style
      
      allow(canvas).to receive(:draw_text)
      
      box.render(canvas)
      
      expect(canvas).to have_received(:draw_text).with(
        1, 0, " Test Header ", anything
      )
    end
  end

  describe '#header=' do
    it 'sets the header text' do
      box.header = "Test Header"
      expect(box.header_text).to eq("Test Header")
    end
  end
end 