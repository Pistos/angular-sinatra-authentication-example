require 'sinatra'
require 'json'
require 'securerandom'

require 'angular-sinatra/models'

before do
  @params = request.params.dup
  begin
    @params.merge JSON.parse(request.body.read)
  rescue JSON::ParserError => e
    # no op, because sometimes JSON parameters are not sent in the body
  end
end

set(:auth) do |_|
  condition {
    @user = AngularSinatra::Model::User[token: @params['token'].to_s]
    @user or halt(403)
  }
end

get '/auth-not-required', provides: 'json' do
  { 'some-key' => 'some-value' }.to_json
end

get '/auth-required', provides: 'json', :auth => true do
  { 'some-private-key' => 'some-private-value' }.to_json
end

post '/tokens', provides: 'json' do
  user = AngularSinatra::Model::User[username: @params['username'].to_s]
  if user.nil?
    404
  elsif user.password == @params['password'].to_s
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
  user = AngularSinatra::Model::User[token: @params['token'].to_s]
  if user
    user.token = nil
    user.save

    200
  else
    404
  end
end

get '/user', provides: 'json' do
  user = AngularSinatra::Model::User[token: @params['token'].to_s]
  return 404  if user.nil?

  {
    'username' => user.username,
    'access' => user.access,
  }.to_json
end