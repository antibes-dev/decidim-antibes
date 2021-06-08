Devise.setup do |config|
  config.omniauth :publik,
                  client_id: ENV["PUBLIK_CLIENT_ID"],
                  client_secret: ENV["PUBLIK_CLIENT_SECRET"],
                  site: ENV["PUBLIK_SITE_URL"],
                  scope: "openid email profile"
end
