module Avatars
  class Utils
    def self.mirror_x!(canvas)
      (0...canvas.width).each do |x|
        (0...canvas.height).each do |y|
          canvas[canvas.width - 1 - x, y] = canvas[x, y]
        end
      end
    end

    def self.mirror_y!(canvas)
      (0...canvas.width).each do |x|
        (0...canvas.height).each do |y|
          canvas[x, canvas.width - 1 - y] = canvas[x, y]
        end
      end
    end

    def self.draw_rect(canvas, x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32, color : StumpyPNG::RGBA)
      (x1..x2).each do |x|
        (y1..y2).each do |y|
          canvas[x, y] = color
        end
      end
    end

    def self.draw_square(canvas, x : Int32, y : Int32, a : Int32, color : StumpyPNG::RGBA)
      (x..x + a).each do |x|
        (y..y + a).each do |y|
          canvas[x, y] = color
        end
      end
    end
  end
end
