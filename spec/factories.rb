require 'factory_girl'
require 'securerandom'
require 'bcrypt'

# require 'angular-sinatra/models'

FactoryGirl.define do
  factory :user, class: AngularSinatra::Model::User do
    username { SecureRandom.hex }
  end
end
