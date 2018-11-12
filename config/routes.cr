Amber::Server.configure do
  pipeline :web do
    # Plug is the method to use connect a pipe (middleware)
    # A plug accepts an instance of HTTP::Handler
    plug Amber::Pipe::PoweredByAmber.new
    # plug Amber::Pipe::ClientIp.new(["X-Forwarded-For"])
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::CSRF.new
  end

  pipeline :api do
    plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::CORS.new
  end

  # All static content will run these transformations
  pipeline :static do
    plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Static.new("./public")
  end

  routes :web do
    get "/grab/:folder/:filename",      GrabController, :index
    # Pages to list files for downloading
    get "/downloads/:folder",           DownloadsController, :index
    # Automated downloader controller
    get "/jdgfh/fgsjkdl/sdjhgklf",      DownloadController, :index
    # Extra pages
    get "/",                            HomeController, :index
    # Api documentation
    get "/apis",                        ApiController, :index
    # Lists files in a folder with json response
    get "/api/list/:folder",            ApiController, :list
    # Details for a file returned in json
    get "/api/file/:folder/:file",      ApiController, :file
  end

  routes :api do
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
