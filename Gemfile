# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", "0.22.0"
# gem "decidim-consultations", "0.22.0"
# gem "decidim-initiatives", "0.22.0"

gem "bootsnap", "~> 1.4"

gem "puma", "~> 4.3.5"
gem "uglifier", "~> 4.1"

gem "faker", "~> 1.9"

gem "figaro"

gem "whenever", require: false

gem "omniauth-publik", git: "https://github.com/OpenSourcePolitics/omniauth-publik"

gem "decidim-term_customizer", git: "https://github.com/mainio/decidim-module-term_customizer", branch: "0.22-stable"

gem "decidim-decidim_awesome", "~> 0.6.2"

gem "decidim-navbar_links", git: "https://github.com/OpenSourcePolitics/decidim-module-navbar_links", branch: "0.22-stable"

gem "decidim-homepage_interactive_map", git: "https://github.com/OpenSourcePolitics/decidim-module-homepage_interactive_map.git", branch: "release/0.22-stable"

gem "decidim-cookies", git: "https://github.com/OpenSourcePolitics/decidim-module_cookies.git", branch: "release/0.22-stable"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", "0.22.0"
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :production do
  gem "daemons"
  gem "delayed_job_active_record"
  gem "passenger"
end
