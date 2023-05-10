# frozen_string_literal: true

class Scheduler::AccountsRemovalScheduler
  include Sidekiq::Worker

  sidekiq_options queue: 'scheduler', retry: 0

  def perform
    return unless Rails.env.production?

    accounts = Account.removed.where('request_remove_at < ?', DateTime.now - 1.day)
    accounts.destroy_all
  end
end
