class GrabController < ApplicationController
  def index
    redirect_to(location: "/", status: 302) if !["spigot", "bukkit", "craftbukkit", "paper", "cauldron", "torch", "tacospigot", "thermos", "mcpc", "hexacord", "pocketmine", "nukkit", "hose", "pixelmon"].includes?(params[:folder].downcase)
    @folder = "#{params[:folder]}"
    if File.exists?("#{Dir.current}/public/files/#{params[:folder]}/#{params[:filename]}.jar")
      @filename = "#{params[:filename]}.jar"
      @page = "Download #{@filename}"
      @url = "https://yivesmirror.com/grab/#{params[:folder]}/#{@filename}"
      render("index.ecr")
    elsif File.exists?("#{Dir.current}/public/files/#{params[:folder]}/#{params[:filename]}.zip")
      @filename = "#{params[:filename]}.zip"
      @page = "Download #{@filename}"
      @url = "https://yivesmirror.com/grab/#{params[:folder]}/#{@filename}"
      render("index.ecr")
    else
      redirect_to(location: "/downloads/#{params[:folder]}", status: 404)
    end
  end
end
