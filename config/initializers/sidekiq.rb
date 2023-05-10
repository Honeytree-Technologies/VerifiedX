if ENV["HEROKU_APP_ID"].present?
  Sidekiq.configure_server do |config|
    config.redis = {ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}}
  end

  Sidekiq.configure_client do |config|
    config.redis = {ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}}
  end
end
require "sidekiq-unique-jobs"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], driver: :hiredis }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], driver: :hiredis }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end