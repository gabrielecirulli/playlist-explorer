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
  unless env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
    redirect "/##{params[:id]}"
  end
  content_type :json
  begin
    open( SINGLE_PLAYLIST_URL % params[:id] ).read
  rescue OpenURI::HTTPError
    { status: 'error', errorMessage: "Couldn't find a Playlist with ID '#{params[:id]}'!" }.to_json
  rescue
    halt 404 # Just in case
  end
end