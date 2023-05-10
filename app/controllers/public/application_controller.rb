class Public::ApplicationController < ApplicationController
  include Public::ApplicationHelper
  layout 'public'

  protected

  def check_login
    logout_user and return unless cookies[:jwt].present?

    client = Mastodon::REST::Client.new(base_url: "https://#{cookies.signed[:jwt]['instance']}",
                                        bearer_token: cookies.signed[:jwt]['token'])
    mastodon_user = client.verify_credentials
    logout_user unless mastodon_user
    mastodon_user
  end

  def logout_user
    cookies.delete :jwt
    cookies.delete :loggedIn
    session.delete :app_info
  end
end
