require "stumpy_png"

class Melter
  def initialize(size : Int32, canvas : StumpyCore::Canvas, path : String)
    @size = size
    @canvas = canvas
    @path = path
    @avatars = [] of StumpyCore::Canvas
  end

  def generate_avatars!
    pixels = @canvas.pixels.to_a.map { |p| [p.red, p.green, p.blue] }

    melted_image = {
      r: pixels.sum { |p| Int64.new(p[0]) },
      g: pixels.sum { |p| Int64.new(p[1]) },
      b: pixels.sum { |p| Int64.new(p[2]) },
    }

    puts pixels.size

    image_count = 3

    puts melted_image

    color_averages = {
      r: melted_image[:r] / pixels.size,
      g: melted_image[:g] / pixels.size,
      b: melted_image[:b] / pixels.size,
    }

    puts color_averages

    color_starts = {
      r: UInt16.new([(color_averages[:r] * 2) - UInt16::MAX, 0].max),
      g: UInt16.new([(color_averages[:g] * 2) - UInt16::MAX, 0].max),
      b: UInt16.new([(color_averages[:b] * 2) - UInt16::MAX, 0].max),
    }

    puts color_starts

    (0...image_count).each do |n|
      canvas = StumpyPNG::Canvas.new(@size, @size)
      c = color_starts.values[n]
      (0...@size).each do |x|
        (0...@size).each do |y|
          color = StumpyPNG::RGBA.from_rgb_n(n == 0 ? c : 0, n == 1 ? c : 0, n == 2 ? c : 0, 16)
          canvas[x, y] = color
          c += (UInt16.new([(color_averages.values[n] * 2), UInt16::MAX].min) - color_starts.values[n]) / (@size ** 2)
        end
      end
      @avatars.push(canvas)
    end
  end

  def avatars
    generate_avatars! if @avatars.empty?
    @avatars
  end

  def save_avatars!
    avatars.map_with_index do |avatar, i|
      StumpyPNG.write(avatar, "#{@path}#{i}.png")
      "#{@path}#{i}.png"
    end
  end
end
