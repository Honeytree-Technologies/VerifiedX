# frozen_string_literal: true

class AccountsCrowlerWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'crowler', retry: 0, lock: :until_and_while_executing,
                  on_conflict: :log

  def perform(id)
    return unless Rails.env.production?

    account = Account.find_by(id: id)
    return unless account

    begin

      account = Account.find id
      return unless account

      account.instance ||= account.mastodon_handle.split('@').last.strip
      return unless account.instance

      mastodon_user = JSON.parse(URI.open("https://#{account.instance}/api/v2/search?q=#{account.mastodon_handle}").read) rescue nil
      mastodon_user = mastodon_user&.[]('accounts')&.first
      unless mastodon_user
        return unless Setting.mastodon_instance

        mastodon_user = JSON.parse(URI.open("#{Setting.mastodon_instance}/api/v2/search?q=#{account.mastodon_handle}").read) rescue nil
        mastodon_user = mastodon_user&.[]('accounts')&.first
        return unless mastodon_user

        instance = mastodon_user['url'].split('/@').first.split('://').last
        mastodon_user = JSON.parse(URI.open("https://#{instance}/api/v2/search?q=#{account.mastodon_handle}").read) rescue nil
        mastodon_user = mastodon_user&.[]('accounts')&.first
      end

      return unless mastodon_user

      account.mastodon_id = mastodon_user['id']
      account.description = mastodon_user['note']
      account.mastodon_account = mastodon_user
      account.crowled_at = DateTime.now
      account.instance = mastodon_user['url'].split('/@').first.split('://').last
      account.save
    rescue StandardError
      nil
    end
  end
end
