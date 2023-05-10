# frozen_string_literal: true

class Scheduler::AccountsCrowlerScheduler
  include Sidekiq::Worker

  sidekiq_options queue: 'scheduler', retry: 0

  def perform
    return unless Rails.env.production?

    empty_instances = Account.where(instance: nil)
    empty_instances.each do |account|
      account.update_columns(instance: account.mastodon_handle.split('@').last.strip)
    end
    instances = Account.order(:crowled_at).group_by{ |p| p.instance }
    instances.each do |instance, accounts|
      accounts.first(100).each do |account|
        AccountsCrowlerWorker.perform_async(account.id)
      end
    end
  end
end
