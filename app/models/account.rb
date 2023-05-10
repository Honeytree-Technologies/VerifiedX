class Account < ApplicationRecord
  # 🚅 add concerns above.
  searchkick

  enum status: %i[pending accepted rejected claimed verified removed]
  enum account_type: %i[people organizations]
  # 🚅 add attribute accessors above.

  belongs_to :team
  belongs_to :region, optional: true
  delegate :country, to: :region, allow_nil: true
  # 🚅 add belongs_to associations above.

  has_and_belongs_to_many :topics

  # 🚅 add has_many associations above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :mastodon_handle, uniqueness: true, presence: true

  # 🚅 add validations above.

  after_create :notify_created
  before_save :set_instance
  after_save :notify_verified
  after_save :check_email
  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def check_email
    return unless saved_change_to_email? && !confirmed?

    request_confirm
  end

  def request_confirm
    return if confirmed?

    self.confirmation_token = SecureRandom.urlsafe_base64(nil, false)
    save
    AccountMailer.confirmation_instructions(self).deliver_later
  end

  def confirm_email!
    self.confirmed_email = email
    save
  end

  def confirmed?
    confirmed_email == email
  end

  def location
    region ? "#{region&.name}, #{region&.country&.name}" : ''
  end

  def job
    text = job_title.to_s
    text += ', ' if text.present?
    text += organisation if organisation
    text
  end

  def long_name
    lname = "#{first_name} #{last_name}"
    lname.strip.empty? ? name : lname
  end

  def label_string
    mastodon_handle
  end

  def country_name
    country&.name
  end

  def region_name
    region&.name
  end

  # TODO notifications service (mailer + mastodon DM)
  def notify_created
    AccountsCrowlerWorker.perform_async(id)
    return unless Setting.creation_dm.present?

    DmSenderWorker.perform_async "#{mastodon_handle}\n#{Setting.creation_dm.gsub('{{mastodon_handle}}',
                                                                                 mastodon_handle)}"
  end

  def notify_verified
    return unless saved_change_to_status? && verified? && Setting.verified_dm.present?

    DmSenderWorker.perform_async "#{mastodon_handle}\n#{Setting.verified_dm.gsub('{{mastodon_handle}}',
                                                                                 mastodon_handle)}"
  end

  def set_instance
    self.instance = mastodon_url&.split('://')&.last&.split('/@')&.first&.strip unless instance
  end

end
