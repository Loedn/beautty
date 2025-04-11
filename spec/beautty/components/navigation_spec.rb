require 'spec_helper'

RSpec.describe Beautty::Components::Navigation do
  let(:navigation) { described_class.new }
  
  describe '#initialize' do
    it 'creates a navigation component with default styles' do
      expect(navigation).to be_a(Beautty::Component)
      expect(navigation.style.width).to eq('100%')
      expect(navigation.style.display).to eq(:flex)
      expect(navigation.style.flex_direction).to eq(:column)
    end
    
    it 'accepts tabs in options' do
      tab1 = Beautty::Components::Text.new("Tab 1 Content")
      tab2 = Beautty::Components::Text.new("Tab 2 Content")
      
      navigation = described_class.new(
        tabs: [
          { id: :tab1, title: "Tab 1", content: tab1 },
          { id: :tab2, title: "Tab 2", content: tab2 }
        ],
        active_tab: 1
      )
      
      expect(navigation.tabs.length).to eq(2)
      expect(navigation.active_tab_index).to eq(1)
      expect(navigation.active_tab_id).to eq(:tab2)
    end
  end
  
  describe '#add_tab' do
    it 'adds a tab to the navigation' do
      tab = Beautty::Components::Text.new("Tab Content")
      navigation.add_tab(:tab1, "Tab 1", tab)
      
      expect(navigation.tabs.length).to eq(1)
      expect(navigation.active_tab_id).to eq(:tab1)
    end
  end
  
  describe '#remove_tab' do
    it 'removes a tab from the navigation' do
      tab1 = Beautty::Components::Text.new("Tab 1 Content")
      tab2 = Beautty::Components::Text.new("Tab 2 Content")
      
      navigation.add_tab(:tab1, "Tab 1", tab1)
      navigation.add_tab(:tab2, "Tab 2", tab2)
      navigation.remove_tab(:tab1)
      
      expect(navigation.tabs.length).to eq(1)
      expect(navigation.active_tab_id).to eq(:tab2)
    end
  end
  
  describe '#set_active_tab' do
    it 'sets the active tab by ID' do
      tab1 = Beautty::Components::Text.new("Tab 1 Content")
      tab2 = Beautty::Components::Text.new("Tab 2 Content")
      
      navigation.add_tab(:tab1, "Tab 1", tab1)
      navigation.add_tab(:tab2, "Tab 2", tab2)
      navigation.set_active_tab(:tab2)
      
      expect(navigation.active_tab_id).to eq(:tab2)
    end
  end
  
  describe '#next_tab and #previous_tab' do
    it 'navigates between tabs' do
      tab1 = Beautty::Components::Text.new("Tab 1 Content")
      tab2 = Beautty::Components::Text.new("Tab 2 Content")
      tab3 = Beautty::Components::Text.new("Tab 3 Content")
      
      navigation.add_tab(:tab1, "Tab 1", tab1)
      navigation.add_tab(:tab2, "Tab 2", tab2)
      navigation.add_tab(:tab3, "Tab 3", tab3)
      
      expect(navigation.active_tab_id).to eq(:tab1)
      
      navigation.next_tab
      expect(navigation.active_tab_id).to eq(:tab2)
      
      navigation.next_tab
      expect(navigation.active_tab_id).to eq(:tab3)
      
      navigation.next_tab
      expect(navigation.active_tab_id).to eq(:tab1) # Wraps around
      
      navigation.previous_tab
      expect(navigation.active_tab_id).to eq(:tab3) # Wraps around
    end
  end
end 