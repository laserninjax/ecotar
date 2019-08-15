require "stumpy_png"
require "stumpy_jpeg"

class ImageReader
  SUPPORTED_FILE_EXTENSIONS = [".png", ".jpg", ".jpeg"]

  def initialize(file : File, extension : String)
    raise "File Not Supported" unless SUPPORTED_FILE_EXTENSIONS.includes?(extension)
    @file = file
    @extension = extension
  end

  def canvas : StumpyCore::Canvas
    case @extension
    when ".png"
      StumpyPNG.read(@file)
    when ".jpg", ".jpeg"
      StumpyJPEG.read(@file)
    else
      raise "Unable to parse image."
    end
  end
end
