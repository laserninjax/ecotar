require "stumpy_png"
require "digest/md5"

module Avatars
  class Default
    @hash : StaticArray(UInt8, 16)

    def initialize(size : Int32, seed : String)
      @size = size
      @hash = Digest::MD5.digest(seed)
      @canvas = StumpyPNG::Canvas.new(@size, @size)
      @generated = false
    end

    def hash
      @hash
    end

    def avatar : StumpyPNG::Canvas
      generate_avatar!
      @canvas
    end

    def save!(path)
      generate_avatar!
      StumpyPNG.write(@canvas, path)
    end

    def generate_avatar!
      return true if @generated

      x = @size / 2
      y = @size / 2

      r = @hash[0]
      g = @hash[1]
      b = @hash[2]

      (0...@size).each do |x|
        (0...@size).each do |y|
          @canvas[x, y] = StumpyPNG::RGBA.from_rgb_n(r, g, b, 8)
        end
      end

      generated = true
    end

    def rgb_components
      pixels = @canvas.pixels.to_a
        .map { |p| [p.red / 256, p.green / 256, p.blue / 256] }

      {
        r:           pixels.sum { |p| Int64.new(p[0]) },
        g:           pixels.sum { |p| Int64.new(p[1]) },
        b:           pixels.sum { |p| Int64.new(p[2]) },
        pixel_count: pixels.size,
      }
    end
  end
end
