require 'spec_helper'

RSpec.describe Beautty do
  it 'has a version number' do
    expect(Beautty::VERSION).not_to be nil
  end
  
  describe '.application' do
    it 'creates a new Application instance' do
      app = Beautty.application
      expect(app).to be_a(Beautty::Application)
    end
    
    it 'evaluates the given block in the context of the application' do
      block_executed = false
      
      Beautty.application do
        block_executed = true
      end
      
      expect(block_executed).to be true
    end
  end
  
  describe Beautty::Application do
    let(:application) { described_class.new }
    
    describe '#initialize' do
      it 'creates a terminal instance' do
        expect(application.terminal).to be_a(Beautty::Terminal)
      end
      
      it 'creates a canvas instance' do
        expect(application.canvas).to be_a(Beautty::Canvas)
      end
      
      it 'sets up a resize handler' do
        terminal = application.terminal
        
        expect(terminal.instance_variable_get(:@resize_callbacks)).not_to be_empty
      end
    end
    
    describe '#start' do
      let(:terminal) { instance_double(Beautty::Terminal) }
      let(:canvas) { instance_double(Beautty::Canvas) }
      
      before do
        allow(Beautty::Terminal).to receive(:new).and_return(terminal)
        allow(Beautty::Canvas).to receive(:new).and_return(canvas)
        allow(terminal).to receive(:width).and_return(80)
        allow(terminal).to receive(:height).and_return(24)
        allow(terminal).to receive(:on_resize)
        allow(terminal).to receive(:raw_mode).and_yield
        allow(terminal).to receive(:read_input).and_return("\u0003") # Ctrl+C to exit loop
        allow(terminal).to receive(:reset)
        allow(canvas).to receive(:render)
      end
      
      it 'puts the terminal in raw mode' do
        application = described_class.new
        application.start
        
        expect(terminal).to have_received(:raw_mode)
      end
      
      it 'renders the canvas' do
        application = described_class.new
        application.start
        
        expect(canvas).to have_received(:render)
      end
      
      it 'resets the terminal when done' do
        application = described_class.new
        application.start
        
        expect(terminal).to have_received(:reset)
      end
      
      it 'yields the canvas to the block if given' do
        yielded_canvas = nil
        
        application = described_class.new
        application.start { |canvas| yielded_canvas = canvas }
        
        expect(yielded_canvas).to eq(canvas)
      end
      
      it 'exits the loop when Ctrl+C is pressed' do
        application = described_class.new
        
        # This should not hang because we're mocking read_input to return Ctrl+C
        application.start
        
        expect(terminal).to have_received(:read_input)
      end
    end
  end
end 