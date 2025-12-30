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
unless ENV['RAILS_ENV'] == 'test' || ENV['RAILS_ENV'] == 'development'
  puts "\n" + "=" * 80
  puts "🔍 CLOUDINARY BOOT DEBUG"
  puts "=" * 80
  puts "Rails ENV: #{ENV['RAILS_ENV']}"
  puts "Cloudinary gem loaded: #{defined?(Cloudinary) ? 'YES' : 'NO'}"

  # Debug: Check what env vars are available
  cloudinary_vars = ENV.select { |k, _| k.start_with?('CLOUDINARY_') }
  puts "\nCloudinary env vars found: #{cloudinary_vars.count}"
  cloudinary_vars.each do |key, value|
    masked_value = value.nil? ? 'NIL' : (value.empty? ? 'EMPTY' : "#{value[0..15]}... (#{value.length} chars)")
    puts "  #{key}: #{masked_value}"
  end

  if defined?(Cloudinary)
    if ENV['CLOUDINARY_URL'].present?
      Cloudinary.config_from_url(ENV['CLOUDINARY_URL'])
      puts "\n✅ Cloudinary configured via CLOUDINARY_URL"
    elsif ENV['CLOUDINARY_CLOUD_NAME'].present? && ENV['CLOUDINARY_API_KEY'].present? && ENV['CLOUDINARY_API_SECRET'].present?
      Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
        config.secure = true
        config.cdn_subdomain = true
      end
      puts "\n✅ Cloudinary configured via individual env vars"
      puts "    Cloud: #{Cloudinary.config.cloud_name}"
      puts "    API Key: #{Cloudinary.config.api_key[0..8]}..."
    else
      puts "\n❌ CLOUDINARY ENV VARS NOT FOUND!"
      puts "Cannot configure Cloudinary - env vars missing"
    end

    # Verify configuration
    if Cloudinary.config.cloud_name && Cloudinary.config.api_key
      puts "\n✅ Cloudinary.config is SET"
      puts "    cloud_name: #{Cloudinary.config.cloud_name}"
      puts "    api_key: #{Cloudinary.config.api_key[0..8]}..."
    else
      puts "\n❌ Cloudinary.config is NOT SET"
    end
  else
    puts "\n❌ Cloudinary gem not loaded yet"
  end

  puts "=" * 80 + "\n"
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
