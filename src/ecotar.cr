require "kemal"
require "uuid"
require "./components/image_smelter"
require "./components/avatars/default"

public_folder "public"

INK_FILE_PATH  = "./ink.txt"
INK_COMPONENTS = {:c => 0_i64, :m => 0_i64, :y => 0_i64, :k => 0_i64}

File.read_lines(INK_FILE_PATH).each_with_index do |c, i|
  INK_COMPONENTS[INK_COMPONENTS.keys[i]] = Int64.new(c)
end

def update_ink(cmyk_components, use_up = false)
  return unless cmyk_components
  {
    c: cmyk_components[:c],
    m: cmyk_components[:m],
    y: cmyk_components[:y],
    k: cmyk_components[:k],
  }.each do |k, v|
    INK_COMPONENTS[k] += (v * (use_up ? -1 : 1))
  end

  File.open(INK_FILE_PATH, "w") do |f|
    INK_COMPONENTS.values.each do |c|
      f.write("#{c}\n".to_slice)
    end
  end
end

macro layout_render(filename)
  render "src/views/#{{{filename}}}.ecr", "src/views/layouts/application.ecr"
end

get "/" do |env|
  avatar_seed = env.params.query["avatar_seed"]?
  layout_render "index"
end

get "/avatar/:seed" do |env|
  avatar_generator = Avatars::Default.new(128, env.params.url["seed"])
  path = "public/avatars/#{avatar_generator.hash.to_slice.hexstring}.png"

  unless File.exists?(path)
    avatar_generator.save!(path) unless File.exists?(path)
    update_ink(avatar_generator.cmyk_components, true)
  end

  send_file env, path, "image/png"
end

post "/smelt" do |env|
  file = env.params.files["file"]
  image_file = ImageFile.new(file.tempfile, file.filename || "untitled")
  update_ink(ImageSmelter.new(image_file).cmyk_components)
  env.redirect "/"
end

Kemal.run
