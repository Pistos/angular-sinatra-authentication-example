require_relative '../server'
require_relative 'factories'
require 'rspec'
require 'rack/test'
require 'json'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

def last_response_data
  JSON.parse(last_response.body)
end
