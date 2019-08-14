require "kemal"

public_folder "assets"

get "/" do
  render "src/views/index.ecr"
end

Kemal.run
