# config/initializers/active_storage.rb

Rails.application.config.active_storage.service_urls_expire_in = 5.minutes # Set the expiration time for URLs
Rails.application.config.active_storage.service_url_scheme = :http # Set the URL scheme (http or https)
Rails.application.routes.default_url_options[:host] = 'localhost' # Set the host
Rails.application.routes.default_url_options[:port] = 3000 # Set the port
