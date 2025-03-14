# frozen_string_literal: true

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
  end
end
