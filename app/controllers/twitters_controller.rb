class TwittersController < ApplicationController
  
  before_filter :link_client, :only => [:new, :create]

  def new
    begin
      if params[:oauth_token] != session[:oauth_request_token_token]
        flash[:error] = 'Could not authorize your Twitter account'
        redirect_to login_path
        return
      end

      oauth_token = session[:oauth_request_token_token]
      oauth_secret = session[:oauth_request_token_secret]

      access_token = @client.authorize(oauth_token, oauth_secret)
      if @client.authorized?
        client_info = @client.info
        @user = User.find_by_twitter_token_and_twitter_secret(access_token.token, access_token.secret)
        if @user
          @user.twitter_token = access_token.token
          @user.twitter_secret = access_token.secret
          @user.twitter_client_info = client_info
          @user.save
        else
          flash[:error] = "Couldn't find a user.Please register for a new account."
          redirect_to signup_path
        end
      end

      session[:oauth_request_token_token] = nil
      session[:oauth_request_token_secret] = nil
      flash[:notice] = 'Logged in successfully'
    rescue
      flash[:error] = 'There was an error during processing the response from Twitter.'
    end

    redirect_to login_path
  end

 
  def create
    request_token = @client.request_token(:oauth_callback => "http://#{request.host_with_port}/twitter/new")

    session[:oauth_request_token_token] = request_token.token
    session[:oauth_request_token_secret] = request_token.secret

    redirect_to request_token.authorize_url
  end

  private

  def link_client
    @client = TwitterOAuth::Client.new(:consumer_key => TWITTER_CONSUMER_KEY, :consumer_secret => TWITTER_CONSUMER_SECRET)
  end

end
