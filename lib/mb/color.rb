# frozen_string_literal: true

require 'matrix'
require 'mb-math'

require_relative 'color/version'

module MB
  # Functions for working with color conversions and colorspaces.
  #
  # Each function should document its expected range, but the typical range is
  # 0..1 for scalar values and 0..360 for angles.  All angles should be in
  # degrees.
  #
  # Most functions should return an Array or Array-compatible object with the
  # color components.
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
      rgb = XYZ_RGB * xyz
      rgb.to_a
    end

    # Convert from linear sRGB to XYZ.  Parameters should typically be in the
    # range 0..1.
    def self.linear_srgb_to_xyz(r, g, b)
      rgb = Vector[r, g, b]
      xyz = RGB_XYZ * rgb
      xyz.to_a
    end

    # Reverse gamma correction to convert linear sRGB values to sRGB.
    # See https://en.wikipedia.org/wiki/SRGB#Definition
    def self.linear_srgb_to_gamma_srgb(r, g, b)
      [r, g, b].map { |v|
        if v <= 0.0031308
          12.92 * v
        else
          1.055 * v ** (1 / 2.4) - 0.055
        end
      }
    end

    # Apply gamma correction to convert sRGB to linear sRGB.
    # See https://en.wikipedia.org/wiki/SRGB#Definition
    def self.gamma_srgb_to_linear_srgb(r, g, b)
      [r, g, b].map { |v|
        if v <= 0.04045
          v / 12.92
        else
          ((v + 0.055) / 1.055) ** 2.4
        end
      }
    end

    # Converts Lch to Lab using a polar to cartesian coordinate conversion.
    # +l+ is typically from 0..1, +c+ from 0..0.5, and h from 0..360.
    # This function should work for any color space that uses a straightforward
    # polar/cylindrical conversion for its color components.
    # See https://en.wikipedia.org/wiki/CIELAB_color_space#Cylindrical_model
    def self.lch_to_lab(l, c, h)
      h_rad = h.degrees
      [
        l,
        c * Math.cos(h_rad),
        c * Math.sin(h_rad),
      ]
    end

    # Converts Lab to Lch using cartesian to polar coordinate transformation.
    # +l+ is usually from 0..1, +a+ and +b+ usually from -0.5..0.5.
    # See #lch_to_lab
    def self.lab_to_lch(l, a, b)
      c = Math.sqrt(a * a + b * b)
      h = Math.atan2(b, a).to_degrees
      h += 360 if h < 0
      [l, c, h]
    end

    # Converts Oklab colors with +l+ typically in 0..1 and +a+ and +b+ in
    # -0.5..0.5 into gamma-corrected sRGB colors from 0..1.
    # Returns an array of [r, g, b].
    def self.oklab_to_rgb(l, a, b)
      x, y, z = oklab_to_xyz(l, a, b)
      lr, lg, lb = xyz_to_linear_srgb(x, y, z)
      linear_srgb_to_gamma_srgb(lr, lg, lb)
    end

    # Converts cylindrical Oklch colors to gamma-corrected sRGB.
    #
    # See #lch_to_lab for parameter ranges.
    def self.oklch_to_rgb(l, c, h)
      l, a, b = lch_to_lab(l, c, h)
      oklab_to_rgb(l, a, b)
    end

    # Converts gamma-corrected sRGB colors in the range 0..1 to Oklab.
    def self.rgb_to_oklab(r, g, b)
      lr, lg, lb = gamma_srgb_to_linear_srgb(r, g, b)
      x, y, z = linear_srgb_to_xyz(lr, lg, lb)
      xyz_to_oklab(x, y, z)
    end

    # Converts gamma-corrected sRGB colors in the range 0..1 to cylindrical
    # Oklch values, with h in degrees.
    def self.rgb_to_oklch(r, g, b)
      lab_to_lch(*rgb_to_oklab(r, g, b))
    end
  end
end
