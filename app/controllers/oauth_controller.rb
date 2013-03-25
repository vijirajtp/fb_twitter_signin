class OauthController < ApplicationController
  
  before_filter :facebook_client, :only => [:facebook_start, :facebook_callback]
  
  def facebook_start
    @oauth_callback_url = "http://#{request.host_with_port}/oauth/facebook_callback"
	  redirect_to @client.auth_code.authorize_url(
	    :redirect_uri => @oauth_callback_url, :scope => 'email')
  end
  
  def facebook_callback
    begin
      @oauth_callback_url = "http://#{request.host_with_port}/oauth/facebook_callback"
      clear_fb_session
    
      error_msg = "There was a problem trying to authenticate you. Please try again."
    
      if (params[:error] and params[:error] != '')
        flash[:error] = error_msg
        redirect_to login_path
      elsif (params[:code] and params[:code] != '')
      
        access_token = @client.auth_code.get_token(params[:code], {:redirect_uri => @oauth_callback_url, :parse => :query})
        if access_token
          session[:fb_access_token] = access_token.token
          session[:fb_user] = get_facebook_contacts(access_token)
          user = User.find(:first, :conditions => ["LOWER(email) = LOWER(?)", session[:fb_user][:email_address]])
          if user
            self.current_user = user
            current_user.update_attribute(:fb_access_token, access_token.token)
            flash[:notice] = "Logged in successfully!!"
            redirect_to home_path
          else
            flash[:notice] = "Please complete your signup below."
            @user = User.new
            @user.first_name = session[:fb_user][:first_name]
            @user.last_name = session[:fb_user][:last_name]
            @user.email_address = session[:fb_user][:email_address]
            redirect_to signup_path
          end
        end
      else
        flash[:error] = error_msg
        redirect_to login_path
      end
    rescue => e
      clear_fb_session
      flash[:error] = "Unable to connect with user account. Please try again."
      redirect_to login_path
    end
  end
  
  def get_facebook_contacts(access_token)
    contact_response = access_token.get('/me', {:parse => :json}).parsed
    user = {
      :email_address => contact_response["email"],
      :full_name => contact_response["name"],
      :first_name => contact_response["first_name"],
      :last_name => contact_response["last_name"]
    }
    return user
  end
  
  protected
	 
  def facebook_client
	  @client ||= OAuth2::Client.new(FACEBOOK_APP_ID, FACEBOOK_SECRET, {:site => FACEBOOK_URL, :token_url => '/oauth/access_token'})
  end
  
end
