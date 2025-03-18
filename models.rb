require 'bundler/setup'
require 'bcrypt'
Bundler.require

ActiveRecord::Base.establish_connection
ActiveRecord::Base.default_timezone = :local

class User < ActiveRecord::Base
    has_secure_password
    has_many :posts
    has_many :comments
    has_many :likes
    has_many :follows
    has_many :notification
    has_many :schedules
    has_many :subscriptions
end

class Post < ActiveRecord::Base
    belongs_to :user
    has_many :comments
    has_many :likes
end

class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :post
end

class Like < ActiveRecord::Base
    belongs_to :user
    belongs_to :post
end

class Schedule < ActiveRecord::Base
    belongs_to :user
end

class Notification < ActiveRecord::Base
    belongs_to :user
end

class Subscription < ActiveRecord::Base
    belongs_to :user
end
