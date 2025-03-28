# frozen_string_literal: true

require 'mb-math'

RSpec.describe MB::Color, :aggregate_failures do
  describe '.hsv_to_rgb' do
    it 'returns red rgb=[1,0,0] for hsv=[0,1,1]' do
      expect(MB::Color.hsv_to_rgb(0, 1, 1)).to eq([1, 0, 0])
    end

    it 'returns green rgb=[0,1,0] for hsv=[1/3,1,1]' do
      expect(MB::Color.hsv_to_rgb(1.0 / 3.0, 1, 1)).to eq([0, 1, 0])
    end

    it 'returns blue rgb=[0,0,1] for hsv=[2/3,1,1]' do
      expect(MB::Color.hsv_to_rgb(2.0 / 3.0, 1, 1)).to eq([0, 0, 1])
    end

    it 'returns red rgb=[1,0,0] for hsv=[1,1,1]' do
      expect(MB::Color.hsv_to_rgb(1, 1, 1)).to eq([1, 0, 0])
    end

    it 'wraps hue around when greater than 1' do
      expect(MB::M.round(MB::Color.hsv_to_rgb(4.0 / 3.0, 1, 1), 6)).to eq([0, 1, 0])
    end

    it 'wraps hue around when less than 0' do
      expect(MB::M.round(MB::Color.hsv_to_rgb(-1.0 / 3.0, 1, 1), 6)).to eq([0, 0, 1])
    end

    it 'varies saturation' do
      expect(MB::M.round(MB::Color.hsv_to_rgb(2.0 / 3.0, 0.0, 1), 6)).to eq([1.0, 1.0, 1.0])
      expect(MB::M.round(MB::Color.hsv_to_rgb(2.0 / 3.0, 0.25, 1), 6)).to eq([0.75, 0.75, 1.0])
      expect(MB::M.round(MB::Color.hsv_to_rgb(2.0 / 3.0, 0.75, 1), 6)).to eq([0.25, 0.25, 1.0])
    end

    it 'varies value' do
      expect(MB::M.round(MB::Color.hsv_to_rgb(2.0 / 3.0, 0.5, 0), 6)).to eq([0.0, 0.0, 0.0])
      expect(MB::M.round(MB::Color.hsv_to_rgb(2.0 / 3.0, 0.5, 0.25), 6)).to eq([0.125, 0.125, 0.25])
      expect(MB::M.round(MB::Color.hsv_to_rgb(2.0 / 3.0, 0.5, 0.75), 6)).to eq([0.375, 0.375, 0.75])
    end

    it 'passes through alpha' do
      expect(MB::M.round(MB::Color.hsv_to_rgb(2.0 / 3.0, 0.5, 1, 0.75), 6)).to eq([0.5, 0.5, 1.0, 0.75])
    end

    it 'ramps rgb smoothly across hue' do
      hrange = (-4..4).step(8.0 / 250.0).to_a
      prior = nil
      hrange.each do |h|
        c = Numo::SFloat.cast(MB::M.round(MB::Color.hsv_to_rgb(h, 0.75, 1.0), 6))
        if prior
          d = c - prior
          expect(d.abs.max).to be < 48.0 / 250.0
        end
        prior = c
      end
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

  describe '.xyz_to_linear_srgb' do
    it 'converts red' do
      expect(MB::M.round(MB::Color.xyz_to_linear_srgb(0.4124, 0.2126, 0.0193), 3)).to eq(MB::M.round([1, 0, 0], 3))
    end

    it 'converts green' do
      expect(MB::M.round(MB::Color.xyz_to_linear_srgb(0.3576, 0.7152, 0.1192), 3)).to eq(MB::M.round([0, 1, 0], 3))
    end

    it 'converts blue' do
      expect(MB::M.round(MB::Color.xyz_to_linear_srgb(0.1805, 0.0722, 0.9505), 3)).to eq(MB::M.round([0, 0, 1], 3))
    end
  end

  describe '.linear_srgb_to_xyz' do
    it 'converts red' do
      expect(MB::M.round(MB::Color.linear_srgb_to_xyz(1, 0, 0), 3)).to eq(MB::M.round([0.4124, 0.2126, 0.0193], 3))
    end

    it 'converts green' do
      expect(MB::M.round(MB::Color.linear_srgb_to_xyz(0, 1, 0), 3)).to eq(MB::M.round([0.3576, 0.7152, 0.1192], 3))
    end

    it 'converts blue' do
      expect(MB::M.round(MB::Color.linear_srgb_to_xyz(0, 0, 1), 3)).to eq(MB::M.round([0.1805, 0.0722, 0.9505], 3))
    end
  end

  describe '.linear_srgb_to_gamma_srgb' do
    it 'returns 0 for 0' do
      expect(
        MB::M.round(
          MB::Color.linear_srgb_to_gamma_srgb(0, 0, 0),
          3
        )
      ).to eq(
        MB::M.round(
          [0, 0, 0],
          3
        )
      )
    end

    it 'returns 1 for 1' do
      expect(
        MB::M.round(
          MB::Color.linear_srgb_to_gamma_srgb(1, 1, 1),
          3
        )
      ).to eq(
        MB::M.round(
          [1, 1, 1],
          3
        )
      )
    end

    it 'returns 0.0031308 for 0.0031308' do
      expect(
        MB::M.round(
          MB::Color.linear_srgb_to_gamma_srgb(0.0031308, 0.0031308, 0.0031308),
          3
        )
      ).to eq(
        MB::M.round(
          [0.04045, 0.04045, 0.04045],
          3
        )
      )
    end

    it 'returns the expected values for differing R, G, B' do
      expect(
        MB::M.round(
          MB::Color.linear_srgb_to_gamma_srgb(0, 1, 0.0031308),
          3
        )
      ).to eq(
        MB::M.round(
          [0, 1, 0.04045],
          3
        )
      )
    end

    it 'returns 0.5 for 0.214' do
      expect(MB::Color.linear_srgb_to_gamma_srgb(0.214, 0.214, 0.214)[0]).to be_within(0.001).of(0.5)
    end
  end

  describe '.gamma_srgb_to_linear_srgb' do
    it 'returns 0 for 0' do
      expect(
        MB::M.round(
          MB::Color.gamma_srgb_to_linear_srgb(0, 0, 0),
          3
        )
      ).to eq(
        MB::M.round(
          [0, 0, 0],
          3
        )
      )
    end

    it 'returns 1 for 1' do
      expect(
        MB::M.round(
          MB::Color.gamma_srgb_to_linear_srgb(1, 1, 1),
          3
        )
      ).to eq(
        MB::M.round(
          [1, 1, 1],
          3
        )
      )
    end

    it 'returns 0.0031308 for 0.0031308' do
      expect(
        MB::M.round(
          MB::Color.gamma_srgb_to_linear_srgb(0.04045, 0.04045, 0.04045),
          3
        )
      ).to eq(
        MB::M.round(
          [0.0031308, 0.0031308, 0.0031308],
          3
        )
      )
    end

    it 'returns the expected values for differing R, G, B' do
      expect(
        MB::M.round(
          MB::Color.gamma_srgb_to_linear_srgb(0, 1, 0.04045),
          3
        )
      ).to eq(
        MB::M.round(
          [0, 1, 0.0031308],
          3
        )
      )
    end

    it 'returns expected value for 0.5' do
      expect(MB::Color.gamma_srgb_to_linear_srgb(0.5, 0.5, 0.5)[0]).to be_within(0.001).of(0.214)
    end
  end

  describe '.lch_to_lab' do
    it 'returns lab=[1, 0.5, 0] for lch=[1, 0.5, 0]' do
      expect(
        MB::M.round(
          MB::Color.lch_to_lab(1, 0.5, 0),
          3
        )
      ).to eq(
        MB::M.round(
          [1, 0.5, 0],
          3
        )
      )
    end

    it 'returns lab=[1, 0, 0.5] for lch=[1, 0.5, 90]' do
      expect(
        MB::M.round(
          MB::Color.lch_to_lab(1, 0.5, 90),
          3
        )
      ).to eq(
        MB::M.round(
          [1, 0, 0.5],
          3
        )
      )
    end

    it 'returns lab=[0.75, -0.5, 0] for lch=[0.75, 0.5, 180]' do
      expect(
        MB::M.round(
          MB::Color.lch_to_lab(0.75, 0.5, 180),
          3
        )
      ).to eq(
        MB::M.round(
          [0.75, -0.5, 0],
          3
        )
      )
    end

    it 'returns lab=[0.5, -0.5, -0.866] for lch[0.5, 1, 240]' do
      expect(
        MB::M.round(
          MB::Color.lch_to_lab(0.5, 1, 240),
          3
        )
      ).to eq(
        MB::M.round(
          [0.5, -0.5, -Math.sqrt(3) / 2],
          3
        )
      )
    end
  end

  describe '.lab_to_lch' do
    it 'returns lch=[1, 0.5, 0] for lab=[1, 0.5, 0]' do
      expect(
        MB::M.round(
          MB::Color.lab_to_lch(1, 0.5, 0),
          3
        )
      ).to eq(
        MB::M.round(
          [1, 0.5, 0],
          3
        )
      )
    end

    it 'returns lch=[1, 0.5, 90] for lab=[1, 0, 0.5]' do
      expect(
        MB::M.round(
          MB::Color.lab_to_lch(1, 0, 0.5),
          3
        )
      ).to eq(
        MB::M.round(
          [1, 0.5, 90],
          3
        )
      )
    end

    it 'returns lch=[0.75, 0.5, 180] for lab=[0.75, -0.5, 0]' do
      expect(
        MB::M.round(
          MB::Color.lab_to_lch(0.75, -0.5, 0),
          3
        )
      ).to eq(
        MB::M.round(
          [0.75, 0.5, 180],
          3
        )
      )
    end

    it 'returns lch=[0.5, 1, 240] for lab[0.5, -0.5, -sqrt(3)/2]' do
      expect(
        MB::M.round(
          MB::Color.lab_to_lch(0.5, -0.5, -Math.sqrt(3) / 2),
          3
        )
      ).to eq(
        MB::M.round(
          [0.5, 1, 240],
          3
        )
      )
    end
  end

  describe '.oklab_to_rgb' do
    it 'returns black rgb=[0, 0, 0] for lab=[0, 0, 0]' do
      expect(
        MB::M.round(
          MB::Color.oklab_to_rgb(0, 0, 0),
          3
        )
      ).to eq(
        [0, 0, 0]
      )
    end

    it 'returns white rgb=[1, 1, 1] for lab=[1, 0, 0]' do
      expect(
        MB::M.round(
          MB::Color.oklab_to_rgb(1, 0, 0),
          3
        )
      ).to eq(
        [1, 1, 1]
      )
    end

    it 'returns an orangish color for lab=[0.7, 0.0, 0.142]' do
      expect(
        MB::M.round(
          MB::Color.oklab_to_rgb(0.7, 0.0, 0.142),
          1
        )
      ).to eq(
        [0.8, 0.6, 0.0]
      )
    end
  end

  describe '.oklch_to_rgb' do
    it 'returns black rgb=[0, 0, 0] for lch=[0, 0, 0]' do
      expect(
        MB::M.round(
          MB::Color.oklch_to_rgb(0, 0, 0),
          3
        )
      ).to eq(
        [0, 0, 0]
      )
    end

    it 'returns white rgb=[1, 1, 1] for lch=[1, 0, 0]' do
      expect(
        MB::M.round(
          MB::Color.oklch_to_rgb(1, 0, 0),
          3
        )
      ).to eq(
        [1, 1, 1]
      )
    end

    it 'returns a reddish color for lch=[0.6, 0.245, 29]' do
      expect(
        MB::M.round(
          MB::Color.oklch_to_rgb(0.6, 0.245, 29),
          1
        )
      ).to eq(
        [0.9, 0, 0]
      )
    end
  end

  describe '.rgb_to_oklab' do
    it 'returns black lab=[0, 0, 0] for rgb=[0, 0, 0]' do
      expect(
        MB::M.round(
          MB::Color.rgb_to_oklab(0, 0, 0),
          3
        )
      ).to eq(
        [0, 0, 0]
      )
    end

    it 'returns white lab=[1, 0, 0] for rgb=[1, 1, 1]' do
      expect(
        MB::M.round(
          MB::Color.rgb_to_oklab(1, 1, 1),
          3
        )
      ).to eq(
        [1, 0, 0]
      )
    end

    it 'returns equal a and b values for grays' do
      _, a, b = MB::M.round(MB::Color.rgb_to_oklab(0.4, 0.4, 0.4), 6)
      expect(a).to be_within(0.0001).of(b)
    end

    it 'returns different a and b values for colors' do
      _, a, b = MB::M.round(MB::Color.rgb_to_oklab(0.4, 0.6, 0.4), 3)
      expect(a).not_to be_within(0.1).of(b)
    end
  end

  describe '.rgb_to_oklch' do
    it 'returns black lch=[0, 0, 0] (ignoring hue) for rgb=[0, 0, 0]' do
      expect(
        MB::M.round(
          MB::Color.rgb_to_oklch(0, 0, 0),
          3
        )[0..1]
      ).to eq(
        [0, 0]
      )
    end

    it 'returns white lch=[1, 0, 0] (ignoring hue) for rgb=[1, 1, 1]' do
      expect(
        MB::M.round(
          MB::Color.rgb_to_oklch(1, 1, 1),
          3
        )[0..1]
      ).to eq(
        [1, 0]
      )
    end

    it 'returns a hue near 240 for a blue/teal color' do
      expect(
        MB::M.sigfigs(
          MB::Color.rgb_to_oklch(0.1, 0.5, 0.8),
          3
        )
      ).to eq(
        [0.582, 0.146, 248]
      )
    end
  end
end
