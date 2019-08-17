require "stumpy_png"
require "digest/md5"
require "./utils"
require "../image_smelter"

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
      generate_avatar! unless @generated
      @canvas
    end

    def save!(path)
      generate_avatar! unless @generated
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

      Avatars::Utils.mirror_x!(@canvas) if @hash[5] > 127
      Avatars::Utils.mirror_y!(@canvas) if @hash[6] > 127

      @generated = true
    end

    def cmyk_components
      generate_avatar! unless @generated
      ImageSmelter.new(@canvas).cmyk_components
    end
  end
end
