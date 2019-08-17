class ImageFile
  getter filename : String
  getter extension : String

  def initialize(file : File, filename : String)
    @file = file
    @filename = filename
    @extension = File.extname((filename || "unsupported").downcase)
  end

  def file : File
    File.open(@file.path)
  end
end
