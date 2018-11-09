class GrabController < ApplicationController
  def index
    redirect_to(location: "/", status: 302) if !["spigot", "bukkit", "craftbukkit", "paper", "cauldron", "torch", "tacospigot", "thermos", "mcpc", "hexacord", "travertine", "pocketmine", "nukkit", "hose", "pixelmon"].includes?(params[:folder].downcase)
    @folder = "#{params[:folder]}"
    if File.exists?("#{Dir.current}/public/files/#{params[:folder]}/#{params[:filename]}")
      @filename = "#{params[:filename]}"
      @page = "Download #{@filename}"
      @url = "https://yivesmirror.com/grab/#{params[:folder]}/#{@filename}"
      render("index.ecr")
    else
      redirect_to(location: "/downloads/#{params[:folder]}", status: 404)
    end
  end
end
