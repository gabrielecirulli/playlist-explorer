require 'sinatra'
require 'open-uri'
require 'JSON'
require 'sinatra/assetpack'

set :sass, { :load_paths => [ "assets/css/" ] }

assets do
  serve '/js',  from: 'assets/js'
  serve '/css', from: 'assets/css'

  css :main, [ '/css/*.css' ]
  js :app,   [
    '/js/vendor/*.js',
    '/js/app/*.js'
  ]

end

# Routing & stuff

get '/' do
  erb :index
end

SINGLE_PLAYLIST_URL = "https://gdata.youtube.com/feeds/api/playlists/%s?v=2&alt=json"

get '/playlist/:id' do
  playlist_id = URI.encode params[:id]
  unless request.xhr?
    redirect "/##{playlist_id}"
  end

  content_type :json
  begin
    open( SINGLE_PLAYLIST_URL % playlist_id ).read
  rescue OpenURI::HTTPError
    { status: 'error', errorMessage: "Couldn't find a Playlist with ID '#{params[:id]}'!" }.to_json
  end
end