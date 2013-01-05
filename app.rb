require 'sinatra'
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

get '/' do
  erb :index
end