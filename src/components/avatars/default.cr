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

      bg_color = StumpyPNG::RGBA.from_rgb_n(r, g, b, 8)
      accent_color = StumpyPNG::RGBA.from_rgb_n(255 - r, 255 - g, 255 - b, 8)

      puts @hash

      (0...@size).each do |x|
        (0...@size).each do |y|
          @canvas[x, y] = squares(x, y) ? accent_color : bg_color
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

    def squares(x, y)
      (x < [@hash[4], @hash[5]].max && x > [@hash[4], @hash[5]].min) && (y < [@hash[6], @hash[7]].max && y > [@hash[6], @hash[7]].min) ||
        (x < [@hash[8], @hash[9]].max && x > [@hash[8], @hash[9]].min) && (y < [@hash[10], @hash[11]].max && y > [@hash[10], @hash[11]].min) ||
        (x < [@hash[12], @hash[13]].max && x > [@hash[12], @hash[13]].min) && (y < [@hash[14], @hash[15]].max && y > [@hash[14], @hash[15]].min)
    end

    def space(x, y)
      Math.sin((x + y + @hash[3]) * @hash[4]).abs * 1000 < @hash[5] ||
        ((x - 30) ** 2 + (y - 30) ** 2) < @hash[9] ** 2 ||
        ((x - @hash[6]/2) ** 2 + (y - @hash[7]/2) ** 2) < (@hash[8] * 2) ** 2 ||
        ((x - @hash[12]/2) ** 2 + (y - @hash[13]/2) ** 2) < (@hash[14] * 2) ** 10 ||
        ((x - @hash[9]/2) ** 2 + (y - @hash[10]/2) ** 2) < (@hash[11] * 2) ** 5
    end
  end
end
