require "./image_file"
require "./image_reader"
require "stumpy_core"

class ImageSmelter
  @rgb_components : NamedTuple(r: Int64, g: Int64, b: Int64, pixel_count: Int64) | Nil
  @cmyk_components : NamedTuple(c: Int64, m: Int64, y: Int64, k: Int64, pixel_count: Int64) | Nil

  def initialize(image : ImageFile | StumpyCore::Canvas)
    @image = image
  end

  def rgb_components
    pixels = if @image.is_a?(ImageFile)
               ImageReader.new(@image.as(ImageFile)).canvas.pixels.to_a
             else
               @image.as(StumpyCore::Canvas).pixels.to_a
             end

    @rgb_components ||= {
      r:           pixels.sum { |p| Int64.new(p.red / 256) },
      g:           pixels.sum { |p| Int64.new(p.green / 256) },
      b:           pixels.sum { |p| Int64.new(p.blue / 256) },
      pixel_count: Int64.new(pixels.size),
    }
  end

  def cmyk_components
    return @cmyk_components if @cmyk_components

    pixel_count = rgb_components[:pixel_count]
    r = rgb_components[:r] / pixel_count
    g = rgb_components[:g] / pixel_count
    b = rgb_components[:b] / pixel_count

    puts "r: #{r}, g: #{g}, b: #{b}"

    rn = r / 255.0
    gn = g / 255.0
    bn = b / 255.0

    puts "r: #{rn}, g: #{gn}, b: #{bn}"

    k = (1 - [rn, gn, bn].max).to_i64
    c = k == 1 ? 0.0 : ((1 - rn - k) / (1 - k)).to_f
    m = k == 1 ? 0.0 : ((1 - gn - k) / (1 - k)).to_f
    y = k == 1 ? 0.0 : ((1 - bn - k) / (1 - k)).to_f

    puts "c: #{c}, m: #{m}, y: #{y}, k: #{k}"

    @cmyk_components = {
      c:           Int64.new(c * pixel_count),
      m:           Int64.new(m * pixel_count),
      y:           Int64.new(y * pixel_count),
      k:           Int64.new(k * pixel_count),
      pixel_count: pixel_count,
    }
  end
end
