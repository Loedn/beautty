require 'spec_helper'

RSpec.describe Beautty::Component do
  let(:component) { described_class.new }
  
  describe '#initialize' do
    it 'creates an empty component' do
      expect(component.parent).to be_nil
      expect(component.children).to be_empty
      expect(component.style).to be_a(Beautty::Style)
    end
    
    it 'accepts style options' do
      component = described_class.new(style: { fg: :red, bg: :blue })
      
      expect(component.style.fg).to eq(:red)
      expect(component.style.bg).to eq(:blue)
    end
    
    it 'accepts children' do
      child1 = described_class.new
      child2 = described_class.new
      
      component = described_class.new(children: [child1, child2])
      
      expect(component.children).to include(child1, child2)
      expect(child1.parent).to eq(component)
      expect(child2.parent).to eq(component)
    end
  end
  
  describe '#add_child' do
    it 'adds a child component' do
      child = described_class.new
      
      component.add_child(child)
      
      expect(component.children).to include(child)
      expect(child.parent).to eq(component)
    end
    
    it 'returns the added child' do
      child = described_class.new
      
      result = component.add_child(child)
      
      expect(result).to eq(child)
    end
  end
  
  describe '#remove_child' do
    it 'removes a child component' do
      child = described_class.new
      component.add_child(child)
      
      component.remove_child(child)
      
      expect(component.children).not_to include(child)
      expect(child.parent).to be_nil
    end
    
    it 'returns the removed child' do
      child = described_class.new
      component.add_child(child)
      
      result = component.remove_child(child)
      
      expect(result).to eq(child)
    end
    
    it 'returns nil if the child is not found' do
      child = described_class.new
      
      result = component.remove_child(child)
      
      expect(result).to be_nil
    end
  end
  
  describe '#calculate_layout' do
    it 'computes the style by merging with parent style' do
      parent_style = Beautty::Style.new(fg: :red)
      component.style = Beautty::Style.new(bg: :blue)
      
      component.calculate_layout(100, 50, parent_style)
      
      expect(component.computed_style.fg).to eq(:red)
      expect(component.computed_style.bg).to eq(:blue)
    end
    
    it 'calculates content size based on available space' do
      component.calculate_layout(100, 50)
      
      expect(component.content_width).to eq(100)
      expect(component.content_height).to eq(50)
    end
    
    it 'respects explicit width and height' do
      component.style = Beautty::Style.new(width: 80, height: 30)
      
      component.calculate_layout(100, 50)
      
      expect(component.content_width).to eq(80)
      expect(component.content_height).to eq(30)
    end
    
    it 'applies min and max constraints' do
      component.style = Beautty::Style.new(
        min_width: 50,
        max_width: 70,
        min_height: 20,
        max_height: 40
      )
      
      # Test min constraints
      component.calculate_layout(30, 10)
      expect(component.content_width).to eq(50)
      expect(component.content_height).to eq(20)
      
      # Test max constraints
      component.calculate_layout(100, 60)
      expect(component.content_width).to eq(70)
      expect(component.content_height).to eq(40)
    end
    
    it 'calculates total size including padding and border' do
      component.style = Beautty::Style.new(
        padding: { top: 2, right: 3, bottom: 4, left: 5 },
        border: true
      )
      
      component.calculate_layout(100, 50)
      
      # Content size
      expect(component.content_width).to eq(100)
      expect(component.content_height).to eq(50)
      
      # Total size (content + padding + border)
      expect(component.width).to eq(100 + 5 + 3 + 2) # content + left + right + border
      expect(component.height).to eq(50 + 2 + 4 + 2) # content + top + bottom + border
    end
  end
  
  describe '#layout_children' do
    context 'with block display' do
      it 'stacks children vertically' do
        parent = described_class.new(style: { width: 100, height: 100 })
        child1 = described_class.new(style: { height: 20 })
        child2 = described_class.new(style: { height: 30 })
        
        parent.add_child(child1)
        parent.add_child(child2)
        
        parent.calculate_layout(100, 100)
        
        expect(child1.y).to eq(0)
        expect(child2.y).to eq(20) # After child1
      end
    end
    
    context 'with flex display and row direction' do
      it 'arranges children horizontally' do
        parent = described_class.new(style: { 
          width: 100, 
          height: 50,
          display: :flex,
          flex_direction: :row
        })
        
        child1 = described_class.new(style: { width: 30 })
        child2 = described_class.new(style: { width: 40 })
        
        parent.add_child(child1)
        parent.add_child(child2)
        
        parent.calculate_layout(100, 50)
        
        expect(child1.x).to eq(0)
        expect(child2.x).to eq(30) # After child1
      end
      
      it 'distributes remaining space according to flex_grow' do
        parent = described_class.new(style: { 
          width: 100, 
          height: 50,
          display: :flex,
          flex_direction: :row
        })
        
        child1 = described_class.new(style: { width: 20, flex_grow: 1 })
        child2 = described_class.new(style: { width: 20, flex_grow: 2 })
        
        parent.add_child(child1)
        parent.add_child(child2)
        
        parent.calculate_layout(100, 50)
        
        # Remaining space: 100 - (20 + 20) = 60
        # child1 gets 60 * (1/3) = 20 extra
        # child2 gets 60 * (2/3) = 40 extra
        expect(child1.width).to eq(20 + 20)
        expect(child2.width).to eq(20 + 40)
      end
    end
    
    context 'with flex display and column direction' do
      it 'arranges children vertically' do
        parent = described_class.new(style: { 
          width: 100, 
          height: 100,
          display: :flex,
          flex_direction: :column
        })
        
        child1 = described_class.new(style: { height: 20 })
        child2 = described_class.new(style: { height: 30 })
        
        parent.add_child(child1)
        parent.add_child(child2)
        
        parent.calculate_layout(100, 100)
        
        expect(child1.y).to eq(0)
        expect(child2.y).to eq(20) # After child1
      end
    end
  end
  
  describe '#render' do
    let(:canvas) { instance_double(Beautty::Canvas) }
    
    before do
      allow(canvas).to receive(:draw_rect)
    end
    
    it 'draws background if specified' do
      component.style = Beautty::Style.new(bg: :blue)
      component.width = 100
      component.height = 50
      component.computed_style = component.style
      
      component.render(canvas)
      
      expect(canvas).to have_received(:draw_rect).with(
        0, 0, 100, 50, fill: true, bg: :blue
      )
    end
    
    it 'draws border if specified' do
      component.style = Beautty::Style.new(border: true, fg: :red)
      component.width = 100
      component.height = 50
      component.computed_style = component.style
      
      component.render(canvas)
      
      expect(canvas).to have_received(:draw_rect).with(
        0, 0, 100, 50, { fg: :red }
      )
    end
    
    it 'renders children' do
      child = instance_double(Beautty::Component)
      allow(child).to receive(:render)
      
      component.add_child(child)
      component.computed_style = component.style
      
      component.render(canvas)
      
      expect(child).to have_received(:render).with(canvas, 0, 0)
    end
  end
end 