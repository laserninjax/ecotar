require "./image_reader"

class ImageSmelter
  def initialize(image : File, extension : String)
    @extension = extension
    @image = image
  end

  def rgb_components
    pixels = ImageReader.new(@image, @extension).canvas
      .pixels
      .to_a
      .map { |p| [p.red / 256, p.green / 256, p.blue / 256] }

    {
      r:           pixels.sum { |p| Int64.new(p[0]) },
      g:           pixels.sum { |p| Int64.new(p[1]) },
      b:           pixels.sum { |p| Int64.new(p[2]) },
      pixel_count: pixels.size,
    }
  end
end
