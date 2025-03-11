require "bundler/setup"
Bundler.require
require "sinatra/reloader" if development?
require "./models.rb"
require_relative "utils/date.rb"

enable :sessions

# セッションの有効期限設定
use Rack::Session::Cookie,
    :path => '/',
    :expire_after => 3600*24,
    :secret => '**unique secret key**'

# ヘルパー関数を定義
helpers do
    def logged_in?
        !!session[:user_id]
    end
end

# 全てのリクエストの前に認証状態更新
before do
    @isAuthed = logged_in?
end

#login,signin,logout
#singin
get '/signup' do
    erb :signup
end

post '/signup' do
    user = User.create(
            name: params[:name],
            email: params[:email],
            password: params[:password],
            password_confirmation: params[:password_confirmation]
            )
    if user.persisted?
        session[:user_id] = user.id
        redirect '/login'
    else
        redirect '/signup'
    end
end

#login
get '/login' do
    erb :login
end

post '/login' do
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect '/'
    else
        redirect '/login'
    end
end

get '/logout' do
    session.clear
    redirect '/login'
end

get '/' do
  erb :index
end