require 'spec_helper'

RSpec.describe Beautty::Components::Container do
  describe '#initialize' do
    it 'creates a container with default flexbox properties' do
      container = described_class.new
      
      expect(container.style.display).to eq(:flex)
      expect(container.style.flex_direction).to eq(:row)
      expect(container.style.justify_content).to eq(:flex_start)
      expect(container.style.align_items).to eq(:stretch)
    end
    
    it 'accepts custom flexbox properties' do
      container = described_class.new(
        direction: :column,
        justify: :center,
        align: :flex_end
      )
      
      expect(container.style.flex_direction).to eq(:column)
      expect(container.style.justify_content).to eq(:center)
      expect(container.style.align_items).to eq(:flex_end)
    end
    
    it 'accepts children in options' do
      child1 = Beautty::Components::Text.new("Child 1")
      child2 = Beautty::Components::Text.new("Child 2")
      
      container = described_class.new(
        children: [child1, child2]
      )
      
      expect(container.children.length).to eq(2)
      expect(container.children).to include(child1)
      expect(container.children).to include(child2)
    end
  end
  
  describe '#add_flex_child' do
    it 'adds a child with flex properties' do
      container = described_class.new
      child = Beautty::Components::Text.new("Flex Child")
      
      container.add_flex_child(child, flex_grow: 1, flex_shrink: 0, flex_basis: 100)
      
      expect(container.children).to include(child)
      expect(child.style.flex_grow).to eq(1)
      expect(child.style.flex_shrink).to eq(0)
      expect(child.style.flex_basis).to eq(100)
    end
  end
  
  describe '.row' do
    it 'creates a container with row direction' do
      container = described_class.row
      
      expect(container.style.flex_direction).to eq(:row)
    end
  end
  
  describe '.column' do
    it 'creates a container with column direction' do
      container = described_class.column
      
      expect(container.style.flex_direction).to eq(:column)
    end
  end
  
  describe '.centered' do
    it 'creates a container with centered content' do
      container = described_class.centered
      
      expect(container.style.justify_content).to eq(:center)
      expect(container.style.align_items).to eq(:center)
    end
  end
  
  describe '.space_between' do
    it 'creates a container with space between items' do
      container = described_class.space_between
      
      expect(container.style.justify_content).to eq(:space_between)
    end
  end
  
  describe '.space_around' do
    it 'creates a container with space around items' do
      container = described_class.space_around
      
      expect(container.style.justify_content).to eq(:space_around)
    end
  end
end 