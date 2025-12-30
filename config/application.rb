require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Configure Cloudinary EARLY (before application initialization)
# This ensures global config is available for Active Storage integrity checks
if defined?(Cloudinary) && !Rails.env.test?
  if ENV['CLOUDINARY_URL'].present?
    Cloudinary.config_from_url(ENV['CLOUDINARY_URL'])
    puts "🌩️  Cloudinary configured via CLOUDINARY_URL"
  elsif ENV['CLOUDINARY_CLOUD_NAME'].present? && ENV['CLOUDINARY_API_KEY'].present? && ENV['CLOUDINARY_API_SECRET'].present?
    Cloudinary.config do |config|
      config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
      config.api_key = ENV['CLOUDINARY_API_KEY']
      config.api_secret = ENV['CLOUDINARY_API_SECRET']
      config.secure = true
      config.cdn_subdomain = true
    end
    puts "🌩️  Cloudinary configured via individual env vars"
    puts "    Cloud: #{ENV['CLOUDINARY_CLOUD_NAME']}, Key: #{ENV['CLOUDINARY_API_KEY'][0..8]}..."
  else
    puts "⚠️  Cloudinary env vars not found at boot time"
  end
end

module Nachinacon
  class Application < Rails::Application
    # Set secret_key_base from ENV or use fallback
    config.secret_key_base = ENV["SECRET_KEY_BASE"] || "22232afe6df956bedfdc6614c0817e1402fac73cd5820ab60679e97122ebfa6ef078f51bbb02819abf15701a0b9579a712cee37c8bc409f2ba3fd81ca4bbd07d"

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Use MiniMagick for image processing (libvips not installed)
    config.active_storage.variant_processor = :mini_magick
  end
end
