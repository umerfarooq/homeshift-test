Capybara::Webkit.configure do |config|

	config.debug = false

	# Don't raise errors when SSL certificates can't be validated
  config.ignore_ssl_errors

  # Don't load images
  config.skip_image_loading
end