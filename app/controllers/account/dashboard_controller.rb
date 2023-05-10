class Account::DashboardController < Account::ApplicationController
  require 'mastodon'

  def index
    redirect_to account_team_path current_team
  end

  def settings
    return unless request.method == 'POST'

    Setting.mastodon_instance = params[:mastodon_instance]
    Setting.mastodon_access_token = params[:mastodon_access_token]
    Setting.privacy_policy = params[:privacy_policy]
    Setting.terms_of_use = params[:terms_of_use]
    Setting.disclaimer = params[:disclaimer]
    Setting.about = params[:about]
    Setting.faq = params[:faq]
    Setting.creation_dm = params[:creation_dm]
    Setting.verified_dm = params[:verified_dm]
    Setting.home_title = params[:home_title]
    Setting.home_text = params[:home_text]
    Setting.home_button = params[:home_button]
    Setting.search_engine_title = params[:search_engine_title]
    Setting.application_name = params[:application_name]
    Setting.application_title = params[:application_title]
    Setting.feed_title = params[:feed_title]
    Setting.feed_text = params[:feed_text]
    Setting.application_description = params[:application_description]
    Setting.application_keywords = params[:application_keywords]
    Setting.application_upper_url = params[:application_upper_url]
    Setting.application_profile = params[:application_profile]
    Setting.jobs_list = params[:jobs_list]
    Setting.organisation_types = params[:organisation_types]
    Setting::ATTACHMENT_ATTRIBUTES.each do |attribute|
      if params[attribute].present?
        Setting.send("#{attribute}=", params[attribute])
      elsif params["#{attribute}_remove".to_sym] == 'true'
        Setting.send("#{attribute}=", nil)
      end
    end
  end
end
