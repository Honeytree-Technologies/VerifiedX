# frozen_string_literal: true

class DmSenderWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'dms', retry: 0, lock: :until_and_while_executing,
                  on_conflict: :log

  def perform(dm)
    return unless Rails.env.production?

    client = Mastodon::REST::Client.new(base_url: Setting.mastodon_instance,
                                        bearer_token: Setting.mastodon_access_token)
    return unless client.verify_credentials

    client.create_status(dm, visibility: 'direct')
    Rails.logger.info "sent dm : #{dm}"
  end
end
