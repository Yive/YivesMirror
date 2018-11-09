require "cossack"

class DownloadController < ApplicationController
  def index
    array = ["bukkit","craftbukkit","spigot","paper","tacospigot","hexacord","torch","pocketmine","nukkit","travertine", "minecraft"]
    array.each do |check|
      if check == "minecraft"
        check_version_json = Cossack.get("https://launchermeta.mojang.com/mc/game/version_manifest.json").body
        if check_version_json.empty?
          puts "Skipping #{check}."
          next
        end
        begin
          puts "Grabbing version_manifest.json"
          Process.new("wget https://launchermeta.mojang.com/mc/game/version_manifest.json -O #{Dir.current}/version_manifest.json", shell: true)
        rescue e
          puts e.message; next
        end
        next
      end
      if check == "paper"
        check_json = Cossack.get("http://auto.tcpr.ca/glb.php?check=paperspigot").body
      else
        check_json = Cossack.get("http://auto.tcpr.ca/glb.php?check=#{check}").body
      end
      if check_json.empty?
        puts "Skipping #{check}."
        next
      end
      check_json = JSON.parse(check_json)
      check_json.as_h.each do |key, file|
        if Time.now.epoch - check_json["#{key}"]["date"].as_i64 < 3600
          next if "#{check_json["#{key}"]["url"]}".nil?
          begin
            puts "Grabbing #{check_json["#{key}"]["name"]}"
            Process.new("wget #{check_json["#{key}"]["url"]} -O #{Dir.current}/public/files/#{check}/#{check_json["#{key}"]["name"]} && touch --date=@#{check_json["#{key}"]["date"]} #{Dir.current}/public/files/#{check}/#{check_json["#{key}"]["name"]}", shell: true)
          rescue e
            puts e.message; next
          end
        end
      end
    end
  end
end
