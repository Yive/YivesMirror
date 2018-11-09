class HomeController < ApplicationController
  def index
    @page = "Home"
    @url = "https://yivesmirror.com/"
    render("index.ecr")
  end
end

