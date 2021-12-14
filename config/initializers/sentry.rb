# frozen_string_literal: true

require "sentry-ruby"

if Rails.application.secrets.dig(:sentry, :enabled)
  Sentry.init do |config|
    config.dsn = Rails.application.secrets.dig(:sentry, :dsn)
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    config.traces_sample_rate = ENV.fetch("SENTRY_SAMPLE_RATE", 0.5)
  end
end
