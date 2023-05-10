# RailsSettings Model
class Setting < RailsSettings::Base
  has_one_attached :attachment

  cache_prefix { 'v1' }

  field :mastodon_instance, type: :string
  field :mastodon_access_token, type: :string
  field :privacy_policy, type: :text
  field :terms_of_use, type: :text
  field :about, type: :text
  field :faq, type: :text
  field :disclaimer, type: :text, default: I18n.t('settings.disclaimer')
  field :home_title, type: :text, default: I18n.t('settings.home.home_title')
  field :home_text, type: :text, default: I18n.t('settings.home.home_text')
  field :home_button, type: :string, default: I18n.t('settings.home.home_button')
  field :search_engine_title, type: :string, default: I18n.t('settings.home.search_engine_title')
  field :feed_title, type: :string, default: I18n.t('settings.feed.feed_title')
  field :feed_text, type: :string, default: I18n.t('settings.feed.feed_text')
  field :application_name, type: :string, default: I18n.t('application.name')
  field :application_title, type: :string, default: I18n.t('application.title')
  field :application_description, type: :string, default: I18n.t('application.description')
  field :application_keywords, type: :string, default: I18n.t('application.keywords')
  field :application_upper_url, type: :string, default: I18n.t('application.name')
  field :application_profile, type: :string, default: 'Profile'
  field :creation_dm, type: :string
  field :verified_dm, type: :string
  field :jobs_list, type: :text
  field :organisation_types, type: :text


  ATTACHMENT_ATTRIBUTES = %i[
    application_logo
    application_logo_dark
    application_favicon
    application_apple_icon
    application_og_image
  ].freeze

  ATTACHMENT_ATTRIBUTES.each do |name|
    field name, type: :string
    define_singleton_method(name) do
      find_by(var: name)
    end

    define_singleton_method("#{name}=") do |io, **options|
      setting = find_or_create_by(var: name)
      if io
        setting.update_columns(value: name)
        setting.attachment.attach(io, **options)
      else
        setting.attachment.purge
        setting.update_columns(value: nil)
      end
    end
  end

  # Define your fields
  # field :host, type: :string, default: "http://localhost:3000"
  # field :default_locale, default: "en", type: :string
  # field :confirmable_enable, default: "0", type: :boolean
  # field :admin_emails, default: "admin@rubyonrails.org", type: :array
  # field :omniauth_google_client_id, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] || ""), type: :string, readonly: true
  # field :omniauth_google_client_secret, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] || ""), type: :string, readonly: true

  def self.mastodon_user
    Mastodon::REST::Client.new(base_url: Setting.mastodon_instance,
                               bearer_token: Setting.mastodon_access_token).verify_credentials
  rescue StandardError
    nil
  end
end
