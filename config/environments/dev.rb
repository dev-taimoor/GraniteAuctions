require "active_support/core_ext/integer/time"

Rails.application.configure do
  Rails.application.credentials.application_host

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.assets.compile = false


  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?


  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]


  config.action_mailer.perform_caching = false

  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'granite-auction.jointhefleet.com',
    user_name: 'graniteauction@gmail.com',
    password: 'fjfH8fMNSR8kW$m',
    authentication: 'plain',
    enable_starttls_auto: true
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: 'granite-auction.jointhefleet.com' }

  config.action_mailer.raise_delivery_errors = true

  config.i18n.fallbacks = false

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
