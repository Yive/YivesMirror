require "cossack"

class DownloadController < ApplicationController
  def index
    check_version_json = Cossack.get("https://launchermeta.mojang.com/mc/game/version_manifest.json").body
    if check_version_json.empty?
      puts "Skipping MC manifest grab."
    end
    begin
      puts "Grabbing version manifest"
      Process.new("wget https://launchermeta.mojang.com/mc/game/version_manifest.json -O #{Dir.current}/version_manifest.json", shell: true)
    rescue e
      puts e.message
    end
  end
end
