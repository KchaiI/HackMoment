require "bundler/setup"
Bundler.require
require "sinatra/reloader" if development?
require "./models.rb"
require_relative "utils/date.rb"

get '/' do
  erb :index
end