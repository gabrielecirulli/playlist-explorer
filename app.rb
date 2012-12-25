require 'sinatra'
require 'sinatra/assetpack'

assets do
  serve '/js',  from: 'assets/js'
  serve '/css', from: 'assets/css'

  css :main, [ '/css/*.css' ]
  js :app,   [ '/js/*.js' ]
end

get '/' do
  erb :index
end

get '/fuck' do
  'shit'
end

get '/hello' do
  'asdf'
end