# frozen_string_literal: true

require 'matrix'

require_relative "color/version"

module MB
  module Color
    # Converts HSV in the range 0..1 to RGB in the range 0..1.  Alpha is
    # returned unmodified if present, omitted if nil.
    def self.hsv_to_rgb(h, s, v, a = nil, buf: [])
      # https://en.wikipedia.org/wiki/HSL_and_HSV#HSV_to_RGB

      h = h.to_f
      s = s.to_f
      v = v.to_f

      h = 0 if h.nan?
      h = 0 if h < 0 && h.infinite?
      h = 1 if h > 1 && h.infinite?
      h = h % 1 if h < 0 || h > 1
      c = v.to_f * s.to_f
      h *= 6.0
      x = c.to_f * (1 - ((h % 2) - 1).abs)
      case h.floor
      when 0
        r, g, b = c, x, 0
      when 1
        r, g, b = x, c, 0
      when 2
        r, g, b = 0, c, x
      when 3
        r, g, b = 0, x, c
      when 4
        r, g, b = x, 0, c
      else
        r, g, b = c, 0, x
      end

      m = v - c

      buf[0] = r + m
      buf[1] = g + m
      buf[2] = b + m

      if a
        buf[3] = a
      else
        buf.delete_at(3)
      end

      buf
    end

    # M1 from the XYZ-to-Oklab conversion
    # See https://bottosson.github.io/posts/oklab/
    XYZ_OKLAB_M1 = Matrix[
      [ 0.8189330101, 0.0329845436, 0.0482003018],
      [ 0.3618667424, 0.9293118715, 0.2643662691],
      [-0.1288597137, 0.0361456387, 0.6338517070],
    ].transpose.freeze

    # M2 from the XYZ-to-Oklab conversion
    XYZ_OKLAB_M2 = Matrix[
      [ 0.2104542553,  1.9779984951,  0.0259040371],
      [ 0.7936177850, -2.4285922050,  0.7827717662],
      [-0.0040720468,  0.4505937099, -0.8086757660],
    ].transpose.freeze

    # M1 inverse for Oklab-to-XYZ
    OKLAB_XYZ_M1 = XYZ_OKLAB_M1.inverse.freeze

    # M2 inverse for Oklab-to-XYZ
    OKLAB_XYZ_M2 = XYZ_OKLAB_M2.inverse.freeze

    # Matrix for converting XYZ to linear RGB.
    RGB_XYZ = Matrix[
      [0.4124, 0.3576, 0.1805],
      [0.2126, 0.7152, 0.0722],
      [0.0193, 0.1192, 0.9505],
    ].freeze

    # Matrix for converting linear RGB to XYZ.
    XYZ_RGB = RGB_XYZ.inverse.freeze

    # Convert from XYZ to Oklab.  Parameters are floating point values [TODO:
    # add ranges; probably 0-1].  Returns an array with [L, a, b] commonly in
    # the range [0..1, -0.5..0.5, -0.5..0.5], but values may exceed the typical
    # range.
    def self.xyz_to_oklab(x, y, z)
      xyz = Vector[x, y, z]

      lms = XYZ_OKLAB_M1 * xyz
      lms_prime = Vector[
        Math.cbrt(lms[0]),
        Math.cbrt(lms[1]),
        Math.cbrt(lms[2]),
      ]

      lab = XYZ_OKLAB_M2 * lms_prime

      lab.to_a
    end

    # Convert from Oklab to XYZ.
    def self.oklab_to_xyz(l, a, b)
      lab = Vector[l, a, b]

      lms_prime = OKLAB_XYZ_M2 * lab
      lms = Vector[
        lms_prime[0] ** 3,
        lms_prime[1] ** 3,
        lms_prime[2] ** 3,
      ]

      xyz = OKLAB_XYZ_M1 * lms

      xyz.to_a
    end

    # Convert from XYZ to linear sRGB.  Returns an Array of linear [R, G, B]
    # typically in the range of 0..1.
    def self.xyz_to_linear_srgb(x, y, z)
      xyz = Vector[x, y, z]
      rgb = RGB_XYZ * xyz

      require 'pry-byebug'; binding.pry # XXX

      rgb.to_a
    end

    # Apply gamma correction to convert linear sRGB values to sRGB.
    def self.linear_srgb_to_srgb(r, g, b)
      raise NotImplementedError, 'TODO'
    end

    def self.oklab_to_rgb(l, a, b)
      raise NotImplementedError, 'TODO'
    end

    def self.oklch_to_rgb(l, c, h)
      raise NotImplementedError, 'TODO'
    end

    def self.rgb_to_oklab(r, g, b)
      raise NotImplementedError, 'TODO'
    end
  end
end
