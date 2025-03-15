require "bundler/setup"
Bundler.require
require "sinatra/reloader" if development?
require 'fileutils'
require 'securerandom'
require 'active_support/all'
require "json"
require "date"

set :public_folder, 'public'
require_relative "utils/date.rb"

Time.zone = 'Asia/Tokyo'
ActiveRecord::Base.default_timezone = :local

require "./models.rb"
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
        icon_url: icon_url,
        created_at: Time.now.in_time_zone('Asia/Tokyo')
    )
    puts "User create time #{user.created_at}"
    
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
        img_url = nil

        if params[:img] && params[:img][:tempfile]
            filename = params[:img][:filename]
            tempfile = params[:img][:tempfile]
    
            unique_filename = "#{SecureRandom.uuid}_#{filename}"
            save_path = "./public/uploads/#{unique_filename}"
    
            # 画像を保存
            File.open(save_path, 'wb') do |f|
                f.write(tempfile.read)
            end
    
            # DBには相対パスを保存
            img_url = "/uploads/#{unique_filename}"
        end
        
        post = Post.create(
                img: img_url,
                text: params[:text],
                user_id: session[:user_id]
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

# スケジュールデータを取得（FullCalendar に渡す）
get "/events" do
  content_type :json
  events = Schedule.all.map do |schedule|
    {
      id: schedule.id,
      title: schedule.title,
      start: schedule.start_time.iso8601,
      end: schedule.end_time.iso8601
    }
  end
  events.to_json
end


post "/schedules" do
  request_data = JSON.parse(request.body.read)

  schedule = Schedule.new(
    title: request_data["title"],
    start_time: DateTime.parse(request_data["start_time"]),
    end_time: DateTime.parse(request_data["end_time"])
  )

  if schedule.save
    status 201
    schedule.to_json
  else
    status 400
    { errors: schedule.errors.full_messages }.to_json
  end
end

