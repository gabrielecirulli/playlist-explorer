require 'sinatra'
require 'open-uri'
require 'JSON'
require 'sinatra/assetpack'

set :sass, load_paths: [ "assets/css/" ]

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

get '/:id' do
  @playlist_id = params[:id]
  erb :index
end

SINGLE_PLAYLIST_FORMAT = "https://gdata.youtube.com/feeds/api/playlists/%s?v=2&max-results=%d&start-index=%d&alt=json"

get '/playlist/:id' do
  playlist_id = URI.encode params[:id]
  unless request.xhr?
    redirect "/#{playlist_id}"
  end

  content_type :json
  begin
    per_page = 50 # Upper result count API limit
    json_result = Hash.new
    10.times do |offset|
      api_url = SINGLE_PLAYLIST_FORMAT % [playlist_id, per_page, offset * per_page + 1]
      json = JSON.parse open( api_url ).read

      if json['feed']['entry']
        if json_result.empty?
          json_result.merge! json
        else
          json_result['feed']['entry'].concat json['feed']['entry']
        end
      else
        break
      end
    end
    
    json_result.to_json # Put out the result
    
  rescue OpenURI::HTTPError
    { status: 'error', errorMessage: "Couldn't find a Playlist with ID '#{params[:id]}'!" }.to_json
  end
end