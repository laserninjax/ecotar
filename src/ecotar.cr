require "kemal"
require "uuid"
require "./components/image_smelter"
require "./components/avatars/default"

public_folder "public"

INK_FILE_PATH  = "/ink.txt"
INK_COMPONENTS = {"cyan" => 0.0, "magenta" => 0.0, "yellow" => 0.0, "black" => 0.0}

macro layout_render(filename)
  render "src/views/#{{{filename}}}.ecr", "src/views/layouts/application.ecr"
end

def rgb_to_cmyk(rgb_components)
  pixel_count = rgb_components[:pixel_count]
  r = rgb_components[:r] / pixel_count.to_f
  g = rgb_components[:g] / pixel_count.to_f
  b = rgb_components[:b] / pixel_count.to_f

  puts "#{r} #{g} #{b}"

  rn = r / 255
  gn = g / 255
  bn = b / 255

  puts "#{rn} #{gn} #{bn}"

  k = 1 - [rn, gn, bn].max

  puts "#{k}"

  c = k == 1 ? 0 : (1 - rn - k) / (1 - k)
  m = k == 1 ? 0 : (1 - gn - k) / (1 - k)
  y = k == 1 ? 0 : (1 - bn - k) / (1 - k)

  {
    "cyan"    => c * pixel_count,
    "magenta" => m * pixel_count,
    "yellow"  => y * pixel_count,
    "black"   => k * pixel_count,
  }
end

def update_ink_from_rgb(rgb_components, use_up = false)
  rgb_to_cmyk(rgb_components).each do |k, v|
    INK_COMPONENTS[k] += (v * (use_up ? -1 : 1))
  end
end

get "/" do
  max_ink_component = INK_COMPONENTS.values.max.to_f
  ink_component_ratios = {
    "cyan"    => INK_COMPONENTS["cyan"].to_f/max_ink_component,
    "magenta" => INK_COMPONENTS["magenta"].to_f/max_ink_component,
    "yellow"  => INK_COMPONENTS["yellow"].to_f/max_ink_component,
    "black"   => INK_COMPONENTS["black"].to_f/max_ink_component,
  }
  layout_render "index"
end

get "/avatar/:seed" do |env|
  avatar_generator = Avatars::Default.new(128, env.params.url["seed"])
  path = "public/avatars/#{avatar_generator.hash.to_slice.hexstring}.png"

  unless File.exists?(path)
    avatar_generator.save!(path) unless File.exists?(path)
    update_ink_from_rgb(avatar_generator.rgb_components, true)
  end

  send_file env, path, "image/png"
end

post "/smelt" do |env|
  file = env.params.files["file"]

  rgb_components = ImageSmelter.new(
    file.tempfile,
    File.extname((file.filename || "unsupported").downcase)
  ).rgb_components

  update_ink_from_rgb(rgb_components)

  env.redirect "/"
end

Kemal.run
