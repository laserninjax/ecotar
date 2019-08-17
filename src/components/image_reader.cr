require "stumpy_png"
require "stumpy_jpeg"

class ImageReader
  SUPPORTED_FILE_EXTENSIONS = [".png", ".jpg", ".jpeg"]

  def initialize(image_file : ImageFile)
    @image_file = image_file
    raise "File Not Supported" unless SUPPORTED_FILE_EXTENSIONS.includes?(image_file.extension)
  end

  def canvas : StumpyCore::Canvas
    case @image_file.extension
    when ".png"
      StumpyPNG.read(@image_file.file)
    when ".jpg", ".jpeg"
      StumpyJPEG.read(@image_file.file)
    else
      raise "Unable to parse image."
    end
  end
end
