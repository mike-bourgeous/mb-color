# frozen_string_literal: true

require 'mb-math'

RSpec.describe MB::Color do
  describe '.hsv_to_rgb' do
    it 'returns rgb=[1,0,0] for hsv=[0,1,1]' do
      expect(MB::Color.hsv_to_rgb(0, 1, 1)).to eq([1, 0, 0])
    end
  end

  describe '.xyz_to_oklab' do
    # https://bottosson.github.io/posts/oklab/
    it 'converts XYZ=[0.95, 1, 1.089] as per spec' do
      expect(MB::M.round(MB::Color.xyz_to_oklab(0.95, 1, 1.089), 3)).to eq(MB::M.round([1, 0, 0], 3))
    end

    it 'converts XYZ=[1, 0, 0] as per spec' do
      expect(MB::M.round(MB::Color.xyz_to_oklab(1, 0, 0), 3)).to eq(MB::M.round([0.45, 1.236, -0.019], 3))
    end

    it 'converts XYZ=[0, 1, 0] as per spec' do
      expect(MB::M.round(MB::Color.xyz_to_oklab(0, 1, 0), 3)).to eq(MB::M.round([0.922, -0.671, 0.263], 3))
    end

    it 'converts XYZ=[0, 0, 1] as per spec' do
      expect(MB::M.round(MB::Color.xyz_to_oklab(0, 0, 1), 3)).to eq(MB::M.round([0.153, -1.415, -0.449], 3))
    end
  end

  describe '.oklab_to_xyz' do
    # https://bottosson.github.io/posts/oklab/
    it 'converts to XYZ=[0.95, 1, 1.089] as per spec' do
      expect(MB::M.round(MB::Color.oklab_to_xyz(1, 0, 0), 2)).to eq(MB::M.round([0.95, 1, 1.089], 2))
    end

    it 'converts to XYZ=[1, 0, 0] as per spec' do
      expect(MB::M.round(MB::Color.oklab_to_xyz(0.45, 1.236, -0.019), 2)).to eq(MB::M.round([1, 0, 0], 2))
    end

    it 'converts to XYZ=[0, 1, 0] as per spec' do
      expect(MB::M.round(MB::Color.oklab_to_xyz(0.922, -0.671, 0.263), 2)).to eq(MB::M.round([0, 1, 0], 2))
    end

    it 'converts to XYZ=[0, 0, 1] as per spec' do
      expect(MB::M.round(MB::Color.oklab_to_xyz(0.153, -1.415, -0.449), 2)).to eq(MB::M.round([0, 0, 1], 2))
    end
  end
end
