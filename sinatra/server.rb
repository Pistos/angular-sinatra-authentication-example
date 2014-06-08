require 'sinatra'
require 'json'
require 'securerandom'

require 'angular-sinatra/models'

set(:auth) do |_|
  condition {
    @user = AngularSinatra::Model::User[token: params['token'].to_s]
    @user or halt(403)
  }
end

get '/auth-not-required' do
  { 'some-key' => 'some-value' }.to_json
end

get '/auth-required', :auth => true do
  { 'some-private-key' => 'some-private-value' }.to_json
end

post '/tokens' do
  user = AngularSinatra::Model::User[username: params['username'].to_s]
  if user.nil?
    404
  elsif user.password == params['password'].to_s
    token = SecureRandom.hex(16)
    user.token = token
    user.save
    {
      'token' => token,
    }.to_json
  else
    401
  end
end

delete '/tokens' do
  user = AngularSinatra::Model::User[token: params['token'].to_s]
  if user
    user.token = nil
    user.save

    200
  else
    404
  end
end
