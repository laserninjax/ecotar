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

      (0...@size).each do |x|
        (0...@size).each do |y|
          @canvas[y, x] =
            StumpyPNG::RGBA.from_rgb_n(
              @hash[0] * Math.sin(2*(x + y)/@hash[1]),
              @hash[2] * Math.cos(2*(x + y)/@hash[3]),
              @hash[4],
              8
            )
        end
      end

      mirror_x! if @hash[5] > 127
      mirror_y! if @hash[6] > 127

      @generated = true
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

    def mirror_x!
      (0...@size).each do |x|
        (0...@size).each do |y|
          @canvas[@size - 1 - x, y] = @canvas[x, y]
        end
      end
    end

    def mirror_y!
      (0...@size).each do |x|
        (0...@size).each do |y|
          @canvas[x, @size - 1 - y] = @canvas[x, y]
        end
      end
    end

    def draw_rect(x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32, color : StumpyPNG::RGBA)
      (x1..x2).each do |x|
        (y1..y2).each do |y|
          @canvas[x, y] = color
        end
      end
    end

    def draw_square(x : Int32, y : Int32, a : Int32, color : StumpyPNG::RGBA)
      (x..x + a).each do |x|
        (y..y + a).each do |y|
          @canvas[x, y] = color
        end
      end
    end
  end
end
