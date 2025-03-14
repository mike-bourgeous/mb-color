# frozen_string_literal: true

RSpec.describe MB::Color do
  describe '.hsv_to_rgb' do
    it 'returns rgb=[1,0,0] for hsv=[0,1,1]' do
      expect(MB::Color.hsv_to_rgb(0, 1, 1)).to eq([1, 0, 0])
    end
  end
end
