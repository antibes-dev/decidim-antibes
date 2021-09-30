if Rails.application.secrets.dig(:sentry, :enabled)
  Sentry.init do |config|
    # config.dsn = 'http://3911b1ade4414a7db38719db21c35a7f@sf-sentry-dev.ville-antibes.fr:9000/2'
    config.dsn = Rails.application.secrets.dig(:sentry, :dsn)
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Set tracesSampleRate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production
    config.traces_sample_rate = 0.5
    # or
    config.traces_sampler = lambda do |context|
      true
    end
  end
end
