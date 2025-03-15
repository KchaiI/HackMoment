require 'bundler'
Bundler.require

require './app'
require 'active_support/all'

ENV['TZ'] = 'Asia/Tokyo'

run Sinatra::Application
