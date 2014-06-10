require 'sinatra'
require 'json'
require 'securerandom'

require 'angular-sinatra/models'

before do
  # This seems to get destroyed the minute we reference request.params.  No idea why.
  original_request_body = request.body.read
  @params = request.params.dup
  begin
    @params.merge! JSON.parse(original_request_body)
  rescue JSON::ParserError => e
    # no op, because sometimes JSON parameters are not sent in the body
  end
end

set(:auth) do |access_level_required|
  condition {
    @user = AngularSinatra::Model::User[token: @params['token'].to_s]
    ( @user && @user.access >= access_level_required ) or halt(403)
  }
end

get '/auth-not-required', provides: 'json' do
  { 'some-key' => 'some-value' }.to_json
end

get '/auth-required', provides: 'json', :auth => 1 do
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

get '/data-only-users-can-see', provides: 'json', auth: 1 do
  {
    'data' => 'must have at least access level 1 to see this',
  }.to_json
end

get '/data-only-admins-can-see', provides: 'json', auth: 5 do
  {
    'data' => 'must have at least access level 5 to see this',
  }.to_json
end

