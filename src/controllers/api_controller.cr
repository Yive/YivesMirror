class ApiController < ApplicationController
  def index
    @page = "APIs"
    @url = "https://yivesmirror.com/apis"
    render("index.ecr")
  end

  def list
    response.status_code = 400
    response.content_type = "application/json"
    if params[:folder] == "all"
      response.status_code = 200
      return ["spigot", "bukkit", "craftbukkit", "paper", "cauldron", "torch", "tacospigot", "thermos", "mcpc", "hexacord", "travertine", "pocketmine", "nukkit", "hose", "pixelmon"].to_pretty_json.to_s
    end
    return "{\"error\": \"Invalid request.\"}" if !["spigot", "bukkit", "craftbukkit", "paper", "cauldron", "torch", "tacospigot", "thermos", "mcpc", "hexacord", "travertine", "pocketmine", "nukkit", "hose", "pixelmon"].includes?(params[:folder].downcase)
    response.status_code = 200
    files = Dir.glob("#{Dir.current}/public/files/#{params[:folder].downcase}/*")
    table = [] of String
    files.each do |file|
      if file.includes?("filepart")
        next
      end
      stat = File.info(file)
      if stat.size == 0
        next
      end
      table = table + [File.basename(file)]
    end
    table.sort! do |one, two|
      (File.info("#{Dir.current}/public/files/#{params[:folder].downcase}/#{two}").modification_time.epoch - File.info("#{Dir.current}/public/files/#{params[:folder].downcase}/#{one}").modification_time.epoch).to_i32
    end
    return table.to_pretty_json.to_s
  end

  def file
    response.status_code = 400
    response.content_type = "application/json"
    return "{\"error\": \"Invalid request.\"}" if !["spigot", "bukkit", "craftbukkit", "paper", "cauldron", "torch", "tacospigot", "thermos", "mcpc", "hexacord", "travertine", "pocketmine", "nukkit", "hose", "pixelmon"].includes?(params[:folder].downcase)
    if !File.exists?("#{Dir.current}/public/files/#{params[:folder].downcase}/#{params[:file]}")
        return "{\"error\": \"File doesn't exist.\"}"
    end
    response.status_code = 200
    versions_file = JSON.parse(File.read("version_manifest.json"))
    @name = "#{params[:folder].capitalize}"
    case @name
    when "Mcpc"
      @name = "MCPC+"
    when "Tacospigot"
      @name = "TacoSpigot"
    when "Paper"
      @name = "Paper"
    when "Bungeecord"
      @name = "BungeeCord"
    when "Hexacord"
      @name = "HexaCord"
    when "Pocketmine"
      @name = "PocketMine"
    when "Craftbukkit"
      @name = "CraftBukkit"
    end
    file = "#{Dir.current}/public/files/#{params[:folder].downcase}/#{params[:file]}"
    if file.includes?("filepart")
      response.status_code = 400
      response.content_type = "application/json"
      return "{\"error\": \"Why are you trying to view a filepart?\"}"
    end
    stat = File.info(file)
    filename = File.basename(file)
    size = "0 Bytes"
    if stat.size / (1024 * 1024) == 0
      if stat.size / 1024 == 0
        size = "#{stat.size} Bytes"
      else
        size = "#{stat.size / 1024} KB"
      end
    else
      size = "#{stat.size / (1024 * 1024)} MB"
    end
    if filename.includes?("latest")
      version = "Latest"
    else
      version = "Unknown"
    end
    versions_file["versions"].as_a.each do |vers|
      if filename.includes?("SNAPSHOT.1060") || filename.includes?("SNAPSHOT.1000") || filename.includes?("CB1060") || filename.includes?("CB1000")
        break version = "1.7.3 Beta"
      elsif filename.includes?(vers["id"].to_s)
        break version = vers["id"].to_s
      elsif filename.includes?("1.13-pre9")
        break version = "1.13 PR9"
      elsif filename.includes?("1.13-pre8")
        break version = "1.13 PR8"
      elsif filename.includes?("1.13-pre7")
        break version = "1.13 PR7"
      elsif filename.includes?("1.12-pre6")
        break version = "1.12 PR6"
      elsif filename.includes?("1.12-pre5")
        break version = "1.12 PR5"
      elsif filename.includes?("1.12-pre2")
        break version = "1.12 PR2"
      elsif filename.includes?("1-6-6 beta")
        break version = "1.6.6 Beta"
      end
    end
    if version == "Unknown"
      if filename.includes?("1.5")
        version = "1.5"
      end
    end
    if @name == "Cauldron"
      if filename.includes?("1.7.10")
        version = "1.7.10"
      end
      if filename.includes?("1.7.2")
        version = "1.7.2"
      end
      if filename.includes?("1.6.4")
        version = "1.6.4"
      end
    end
    if @name == "HexaCord"
      rgex = /HexaCord-v(.*).jar/.match(filename).not_nil![1].to_i32
      if rgex >= 200
        version = "1.7.10 - 1.13.x"
      elsif rgex >= 141 && rgex <= 199
        version = "1.7.10 - 1.12.x"
      elsif rgex >= 101 && rgex <= 140
        version = "1.7.10 - 1.11.x"
      elsif rgex >= 63 && rgex <= 100
        version = "1.7.10 - 1.10.x"
      elsif rgex < 62
        version = "1.7.10 - 1.9.x"
      end
    elsif @name == "Travertine"
      version = "1.7.10 - 1.12.x"
      rgex = /Travertine-b(.*).jar/.match(filename).try &.[1].to_i32
      if rgex.nil?
        rgex = 1
      end
      if rgex > 27
        version = "1.7.10 - 1.13.x"
      elsif rgex < 27
        version = "1.7.10 - 1.12.x"
      end
      if filename.includes?("latest")
        version = "Latest"
      end
    end
    if size == "0 Bytes"
      response.status_code = 400
      response.content_type = "application/json"
      return "{\"error\": \"Issue with file size. Contact Yive with this exact url.\"}"
    end
    insert = {
      "size_human" => size,
      "size_bytes" => stat.size,
      "file_name" => filename,
      "date_human" => stat.modification_time.to_s("%B %-d, %Y"),
      "date_epoch" => stat.modification_time.epoch,
      "mc_version" => version,
      "direct_link" => "https://yivesmirror.com/files/#{params[:folder].downcase}/#{filename}",
      "grab_link" => "https://yivesmirror.com/grab/#{params[:folder].downcase}/#{filename}"
    }
    return insert.to_pretty_json.to_s
  end
end