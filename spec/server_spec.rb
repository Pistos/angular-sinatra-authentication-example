require_relative 'spec_helper'

describe 'The server' do
  context 'when not logged in' do
    it '/auth-not-required returns data' do
      get '/auth-not-required'

      expect(last_response.status).to eq 200
      expect(last_response_data).to eq( { 'some-key' => 'some-value' } )
    end

    it '/auth-required gives an error' do
      get '/auth-required'

      expect(last_response.status).to eq 403
    end
  end

  context 'given an existing User record' do
    before do
      @user = FactoryGirl.build(:user, username: 'joe')
      @user.password = 'mysecret'
      @user.save
    end

    describe 'POST /tokens' do
      it 'with legit credentials provides a token' do
        post '/tokens', 'username' => 'joe', 'password' => 'mysecret'

        expect(last_response.status).to eq 200
        expect(last_response_data['token']).to match /^[a-f0-9]{32}$/
      end

      it 'with legit credentials more than once provides a different token each time' do
        post '/tokens', 'username' => 'joe', 'password' => 'mysecret'
        token1 = last_response_data['token']
        post '/tokens', 'username' => 'joe', 'password' => 'mysecret'
        expect(last_response_data['token']).not_to eq token1
      end

      it 'with bad credentials does not provide a token' do
        post '/tokens', 'username' => 'joe', 'password' => 'badguess'

        expect(last_response.status).not_to eq 200
        expect(last_response.status).to eq 401
      end
    end

    context 'when logged in' do
      before do
        post '/tokens', 'username' => 'joe', 'password' => 'mysecret'
        @token = last_response_data['token']
      end

      it 'GET /auth-not-required returns data' do
        get '/auth-not-required', 'token' => @token

        expect(last_response.status).to eq 200
        expect(last_response_data).to eq( { 'some-key' => 'some-value' } )
      end

      it 'GET /auth-required returns data' do
        get '/auth-required', 'token' => @token

        expect(last_response.status).to eq 200
        expect(last_response_data).to eq( { 'some-private-key' => 'some-private-value' } )
      end

      it 'DELETE /tokens invalidates tokens' do
        delete '/tokens', 'token' => @token
        get '/auth-required', 'token' => @token

        expect(last_response.status).to eq 403
      end

      it 'DELETE /tokens with an invalid token throws an error' do
        delete '/tokens', 'token' => 'nosuchtoken'
        expect(last_response.status).to eq 404
      end
    end
  end
end
