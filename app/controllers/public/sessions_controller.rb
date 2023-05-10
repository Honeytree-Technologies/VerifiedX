class Public::SessionsController < Public::ApplicationController
  skip_before_action :verify_authenticity_token

  # TODO error messages
  def login
    redirect_to root_path and return unless params[:instance]

    client = Mastodon::REST::Client.new(base_url: "https://#{params[:instance]}")
    session[:app_info] = client.create_app(Setting.application_name || 'VerifiedX', "#{request.base_url}/oauth/callback",
                                           :'read:accounts', request.base_url).to_h
    session[:app_info]['instance'] = params[:instance]
    session[:app_info]['referrer'] = request.referrer
    respond_to do |format|
      format.json do
        render json: { success: true,
                       url: "https://#{params[:instance]}/oauth/authorize",
                       client_id: session[:app_info]['client_id'],
                       redirect_uri: session[:app_info]['redirect_uri'] }
      end
    end
  rescue StandardError
    logout_user
    respond_to do |format|
      format.json { render json: { success: false } }
    end
  end

  # TODO error messages
  def callback
    redirect_to root_path and return unless params[:code]

    mastodon_user, token = fetch_login
    redirect_to root_path and return unless mastodon_user

    url = mastodon_user.url.split('/')
    handle = "#{url[-1]}@#{url[-2]}"
    cookies.signed[:jwt] = { value: { handle:, token:, instance: session[:app_info]['instance'] },
                             httponly: true, expires: Time.zone.now + 1.week }
    cookies[:loggedIn] = { value: handle, expires: Time.zone.now + 1.week }
    redirect_to root_path and return unless session[:app_info]['referrer']

    redirect_to session[:app_info]['referrer']
  rescue StandardError
    logout_user
    redirect_to root_path
  end

  def logout
    logout_user
  end

  def request_confirm
    redirect_to root_path and return unless current_account

    current_account.request_confirm
    flash[:notice] = 'Verification instructions have been resent to your email. Please check your inbox and spam folder if you do not see the email within a few minutes.'
  rescue StandardError
    flash[:error] = 'An error occurred when trying to send verification instructions, please try again later.'
  ensure
    redirect_to edit_account_path
  end

  def confirm_email
    unless params[:token].present?
      flash[:error] = 'Invalid confirmation token, please request email confirmation again.'
      redirect_to root_path and return
    end
    @account = Account.find_by confirmation_token: params[:token]
    unless @account
      flash[:error] = 'Invalid confirmation token, please request email confirmation again.'
      redirect_to root_path and return
    end

    @account.confirm_email!
    flash[:notice] = 'Your email has been successfully confirmed!'
    redirect_to root_path

  rescue StandardError
    flash[:error] = 'An error occurred while confirming your email, please request email confirmation again.'
    redirect_to root_path
  end

  private

  def fetch_login
    response = HTTP.post("https://#{session[:app_info]['instance']}/oauth/token",
                         form: { 'code': params[:code], 'scope': 'read:accounts', 'grant_type': 'authorization_code',
                                 'client_id': session[:app_info]['client_id'],
                                 'client_secret': session[:app_info]['client_secret'],
                                 'redirect_uri': session[:app_info]['redirect_uri'] })
    token = JSON.parse(response)['access_token']
    client = Mastodon::REST::Client.new(base_url: "https://#{session[:app_info]['instance']}", bearer_token: token)
    [client.verify_credentials, token]
  rescue StandardError
    nil
  end
end
