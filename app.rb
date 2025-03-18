require "bundler/setup"
Bundler.require
require "sinatra/reloader" if development?
require 'fileutils'
require 'securerandom'
require 'active_support/all'
require "json"
require "date"
require 'sidekiq'
require 'sidekiq/api'
require 'webpush'

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
        redirect '/'
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
    erb :schedule
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


# スケジュール登録#########################
get "/events" do
    content_type :json
    events = Schedule.all.map do |schedule| {
                id: schedule.id,
                start: schedule.start_time.iso8601,
                end: schedule.end_time.iso8601,
                color: "#3788d8",
                display: "background",
                backgroundColor: "#ccc",
                
            }
        end
    events.to_json
end


post "/schedule" do
    request_data = JSON.parse(request.body.read)

    schedule = Schedule.new(
                start_time: DateTime.parse(request_data["start_time"]),
                end_time: DateTime.parse(request_data["end_time"])
            )

    if schedule.save
        delay = (schedule.start_time.to_time - Time.now).to_i
        ScheduleNotifier.perform_in(delay, schedule.id)
        status 201
        schedule.to_json
    else
        status 400
        { errors: schedule.errors.full_messages }.to_json
    end
end


# 通知機能#########################################
# 生成済みの VAPID 秘密鍵/公開鍵を環境変数や設定ファイルで読み込む
VAPID_PUBLIC_KEY  = ENV['VAPID_PUBLIC_KEY']  || "BGvB08SENPxLoe7kA9PYBsvh0go3oMwSpun4eRX0n8iQsod-F5NnWrsYspdKh-B6UUTfBESaZzqhIrOQ77ZRdIc"
VAPID_PRIVATE_KEY = ENV['VAPID_PRIVATE_KEY'] || "j8zxyQ5DkxeY_MLgnYalYn51Sjkut0gXQO3e2Diwwug"
VAPID_SUBJECT     = "mailto:iciak.0127@gmail.com"

post '/subscribe' do
    subscription = JSON.parse(request.body.read)
    Subscription.find_or_create_by(endpoint: subscription["endpoint"]) do |sub|
        sub.p256dh = subscription["keys"]["p256dh"]
        sub.auth = subscription["keys"]["auth"]
        sub.user_id = session[:user_id]
    end
    status 201
end

post '/send_notification' do
    title = params[:title] || "テスト通知タイトル"
    body  = params[:body]  || "テスト通知本文"

    subscriptions = Subscription.all
    subscriptions.each do |sub|
      send_push(sub.endpoint, sub.p256dh, sub.auth, title, body)
    end

    "通知送信しました"
end

def send_push(endpoint, p256dh, auth, title, body)
    Webpush.payload_send(
        endpoint: endpoint,
        message: JSON.dump({ title: title, body: body }),
        p256dh: p256dh,
        auth: auth,
        vapid: {
          subject:     VAPID_SUBJECT,
          public_key:  VAPID_PUBLIC_KEY,
          private_key: VAPID_PRIVATE_KEY
        }
    )
end


class ScheduleNotifier
  include Sidekiq::Worker

  def perform(schedule_id)
    schedule = Schedule.find(schedule_id)
    user = schedule.user

    # ユーザーに紐づいているPush購読情報を取得
    subscriptions = Subscription.where(user_id: user.id)

    # 予定開始時間が近い旨を通知(タイトルや本文はお好みで)
    title = "予定の開始が近づいています"
    body  = "あと5分ほどで予定が始まります（開始: #{schedule.start_time}）"

    subscriptions.each do |sub|
      Webpush.payload_send(
        endpoint: sub.endpoint,
        message:  JSON.dump({ title: title, body: body }),
        p256dh:   sub.p256dh,
        auth:     sub.auth,
        vapid: {
          subject:     "mailto:iciak.0127@gmail.com",
          public_key:  ENV['VAPID_PUBLIC_KEY'],
          private_key: ENV['VAPID_PRIVATE_KEY']
        }
      )
    end
  end
end


get '/notification' do
    
end