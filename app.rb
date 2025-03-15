require "bundler/setup"
Bundler.require
require "sinatra/reloader" if development?
require "./models.rb"
require 'fileutils'
require 'securerandom'
set :public_folder, 'public'
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

#login,signin,logout################################
#singin
get '/signup' do
    erb :signup
end

post '/signup' do
    icon_url = nil

    if params[:file] && params[:file][:tempfile]
        filename = params[:file][:filename]
        tempfile = params[:file][:tempfile]

        unique_filename = "#{SecureRandom.uuid}_#{filename}"
        save_path = "./public/uploads/#{unique_filename}"

        File.open(save_path, 'wb') do |f|
            f.write(tempfile.read)
        end

        icon_url = "/uploads/#{unique_filename}"
    end

    user = User.create(
        name: params[:name],
        email: params[:email],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        icon_url: icon_url
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
###########################################


# get '/' do
#     if @isAuthed
#         post = Post.order(created_at: :desc)
#         erb :home
#     else
#         erb :login
#     end
# end

get '/' do
    erb :signup
end


# 投稿機能#################################
post '/post' do
    if @isAuthed
        post = Post.create(
                img: params[:img],
                text: params[:text],
                # user_id: session[:user_id]
                )
        redirect '/'
    else
        redirect '/login'
    end
end


# 通知機能#################################
get '/notification' do
    
end

# スケジュール登録#########################
post '/schedule' do
    
end

