require 'spec_helper'

RSpec.describe Beautty::Components::Footer do
  let(:footer) { described_class.new }
  
  describe '#initialize' do
    it 'creates a footer component with default styles' do
      expect(footer).to be_a(Beautty::Component)
      expect(footer.style.height).to eq(3)
      expect(footer.style.bg).to eq(:blue)
      expect(footer.style.border).to eq(true)
    end
    
    it 'accepts commands in options' do
      footer = described_class.new(commands: { 'q' => 'Quit', 'h' => 'Help' })
      expect(footer.commands).to include('q' => 'Quit', 'h' => 'Help')
      expect(footer.children.size).to eq(1) # Should have a text component
    end
  end
  
  describe '#add_command' do
    it 'adds a command to the footer' do
      footer.add_command('q', 'Quit')
      expect(footer.commands).to include('q' => 'Quit')
      expect(footer.children.size).to eq(1)
    end
  end
  
  describe '#remove_command' do
    it 'removes a command from the footer' do
      footer.add_command('q', 'Quit')
      footer.add_command('h', 'Help')
      
      footer.remove_command('q')
      
      expect(footer.commands).not_to include('q' => 'Quit')
      expect(footer.commands).to include('h' => 'Help')
    end
  end
  
  describe '#clear_commands' do
    it 'clears all commands' do
      footer.add_command('q', 'Quit')
      footer.add_command('h', 'Help')
      
      footer.clear_commands
      
      expect(footer.commands).to be_empty
    end
  end
end 