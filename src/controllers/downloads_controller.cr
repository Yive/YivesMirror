require "json"

class DownloadsController < ApplicationController
  def index
    redirect_to(location: "/", status: 302) if !["paper", "tacospigot", "thermos", "cauldron", "mcpc", "hexacord", "torch", "hose"].includes?(params[:folder].downcase)
    files = Dir.glob("#{Dir.current}/public/files/#{params[:folder].downcase}/*")
    files.sort! do |one, two|
      (File.info(two).modification_time.to_unix - File.info(one).modification_time.to_unix).to_i32
    end
    table = {} of String => Hash(String, String)
    versions_file = JSON.parse(File.read("version_manifest.json"))
    versions_list = {} of String => String
    @name = "#{params[:folder].capitalize}"
    case @name
    when "Mcpc"
      @name = "MCPC+"
    when "Tacospigot"
      @name = "TacoSpigot"
    when "Paper"
      @name = "Paper"
    when "Hexacord"
      @name = "HexaCord"
    when "Pocketmine"
      @name = "PocketMine"
    end
    @page = "#{@name} Downloads"
    @url = "https://yivesmirror.com/downloads/#{params[:folder]}"
    files.each do |file|
      if file.includes?("filepart")
        next
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
      end
      if size == "0 Bytes"
        next
      end
      insert = {
        "size" => size,
        "filename" => filename,
        "date" => stat.modification_time.to_s("%B %-d, %Y"),
        "version" => version
      }
      if version != "Unknown"
        versions_list[version] = version
      end
      if insert["filename"] != nil
        table[filename] = insert
      end
    end
    render("index.ecr")
  end
end
