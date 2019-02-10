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
      return ["paper", "tacospigot", "thermos", "mcpc", "hexacord"].to_pretty_json.to_s
    end
    return "{\"error\": \"Invalid request.\"}" if !["paper", "tacospigot", "thermos", "mcpc", "hexacord"].includes?(params[:folder].downcase)
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
      (File.info("#{Dir.current}/public/files/#{params[:folder].downcase}/#{two}").modification_time.to_unix - File.info("#{Dir.current}/public/files/#{params[:folder].downcase}/#{one}").modification_time.to_unix).to_i32
    end
    return table.to_pretty_json.to_s
  end

  def file
    response.status_code = 400
    response.content_type = "application/json"
    return "{\"error\": \"Invalid request.\"}" if !["paper", "tacospigot", "thermos", "mcpc", "hexacord"].includes?(params[:folder].downcase)
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
    when "Hexacord"
      @name = "HexaCord"
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
      if filename.includes?(vers["id"].to_s)
        break version = vers["id"].to_s
      end
    end
    if version == "Unknown"
      if filename.includes?("1.5")
        version = "1.5"
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
      "date_epoch" => stat.modification_time.to_unix,
      "mc_version" => version,
      "direct_link" => "https://yivesmirror.com/files/#{params[:folder].downcase}/#{filename}",
      "grab_link" => "https://yivesmirror.com/grab/#{params[:folder].downcase}/#{filename}"
    }
    return insert.to_pretty_json.to_s
  end
end
