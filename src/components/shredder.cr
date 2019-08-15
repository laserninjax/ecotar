require "stumpy_png"

class Shredder
  @pixels : Array(Array(UInt16))

  def initialize(size : Int32, canvas : StumpyCore::Canvas, path : String)
    @size = size
    @canvas = canvas
    @pixels = @canvas.pixels.to_a.map { |p| [p.red, p.green, p.blue] }
    @path = path
    @avatars = [] of StumpyCore::Canvas
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

  def generate_avatars!
    @pixels.shuffle!
    @pixels.sort_by! { |p| p[0] ** (p[1] + p[2]) }

    (0..image_count).map do |n|
      canvas = StumpyPNG::Canvas.new(@size, @size)

      avatar_pixels = @pixels.pop(@size * @size)
      avatar_pixels.shuffle!
      avatar_pixels.sort_by! { |p| p[0] }
      avatar_pixels.shuffle!
      avatar_pixels.sort_by! { |p| p[1] }
      avatar_pixels.shuffle!
      avatar_pixels.sort_by! { |p| p[2] }

      x = 0
      y = 0

      dx = 0
      dy = -1

      (@size * @size).times do |i|
        if (-@size/2 < x <= @size/2) && (-@size/2 < y <= @size/2)
          pixel = avatar_pixels.pop
          color = StumpyCore::RGBA.from_rgb8(pixel[0], pixel[1], pixel[2])
          canvas[x + @size/2 - 1, y + @size/2 - 1] = color
        end

        if x == y || (x < 0 && x == -y) || (x > 0 && x == 1 - y)
          dx, dy = -dy, dx
        end

        x, y = x + dx, y + dy
      end

      @avatars.push(canvas)
    end
  end

  private def image_count
    (@pixels.size / (@size * @size)).floor - 1
  end
end
