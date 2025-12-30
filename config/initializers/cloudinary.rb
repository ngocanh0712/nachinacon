# frozen_string_literal: true

# Cloudinary configuration for Active Storage
# https://cloudinary.com/documentation/rails_activestorage

# Configure in all environments except development/test
# Railway might use 'production', 'staging', or other custom environments
unless Rails.env.development? || Rails.env.test?
  Rails.logger.info "=" * 80
  Rails.logger.info "Initializing Cloudinary for environment: #{Rails.env}"
  Rails.logger.info "=" * 80

  # CRITICAL FIX: Read credentials from Active Storage config instead of ENV
  # This ensures we use the SAME credentials that storage.yml has
  begin
    storage_config = Rails.configuration.active_storage.configurations[:cloudinary]

    if storage_config && storage_config['cloud_name'].present? && storage_config['api_key'].present?
      Rails.logger.info "✅ Found Cloudinary credentials in storage.yml"
      Rails.logger.info "   Configuring Cloudinary.config from storage config..."

      Cloudinary.config do |config|
        config.cloud_name = storage_config['cloud_name']
        config.api_key = storage_config['api_key']
        config.api_secret = storage_config['api_secret']
        config.secure = true
        config.cdn_subdomain = true
      end

      Rails.logger.info "✅ Cloudinary.config successfully set from storage.yml"
      Rails.logger.info "   Cloud: #{Cloudinary.config.cloud_name}"
      Rails.logger.info "   API Key: #{Cloudinary.config.api_key[0..8]}..."
    elsif ENV['CLOUDINARY_URL'].present?
    # CLOUDINARY_URL format: cloudinary://api_key:api_secret@cloud_name
    Rails.logger.info "Cloudinary: Using CLOUDINARY_URL"
    Cloudinary.config_from_url(ENV['CLOUDINARY_URL'])
  elsif ENV['CLOUDINARY_CLOUD_NAME'].present? && ENV['CLOUDINARY_API_KEY'].present? && ENV['CLOUDINARY_API_SECRET'].present?
    # Fallback to individual env vars
    Rails.logger.info "Cloudinary: Configuring with individual env vars"
    Rails.logger.info "Cloudinary: cloud_name=#{ENV['CLOUDINARY_CLOUD_NAME']}"
    Rails.logger.info "Cloudinary: api_key=#{ENV['CLOUDINARY_API_KEY'][0..5]}..." if ENV['CLOUDINARY_API_KEY']

    Cloudinary.config do |config|
      config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
      config.api_key = ENV['CLOUDINARY_API_KEY']
      config.api_secret = ENV['CLOUDINARY_API_SECRET']
      config.secure = true
      config.cdn_subdomain = true
    end
  else
      # Missing configuration - log detailed error
      Rails.logger.error "=" * 80
      Rails.logger.error "CLOUDINARY CONFIGURATION ERROR"
      Rails.logger.error "=" * 80
      Rails.logger.error "Missing Cloudinary credentials in BOTH storage.yml and ENV"
      Rails.logger.error ""
      Rails.logger.error "Storage config: #{storage_config.inspect}"
      Rails.logger.error "ENV vars present: CLOUDINARY_URL=#{ENV['CLOUDINARY_URL'].present?}, CLOUD_NAME=#{ENV['CLOUDINARY_CLOUD_NAME'].present?}"
      Rails.logger.error "=" * 80
    end
  rescue => e
    Rails.logger.error "❌ Error loading Cloudinary config from storage.yml: #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
  end

  # Verify final configuration
  if Cloudinary.config.cloud_name.present? && Cloudinary.config.api_key.present?
    Rails.logger.info "=" * 80
    Rails.logger.info "✅✅✅ CLOUDINARY FULLY CONFIGURED ✅✅✅"
    Rails.logger.info "   Cloud Name: #{Cloudinary.config.cloud_name}"
    Rails.logger.info "   API Key: #{Cloudinary.config.api_key[0..8]}..."
    Rails.logger.info "   This should fix the 'Must supply api_key' error!"
    Rails.logger.info "=" * 80
  else
    Rails.logger.error "=" * 80
    Rails.logger.error "❌ CLOUDINARY STILL NOT CONFIGURED"
    Rails.logger.error "   Config: #{Cloudinary.config.inspect}"
    Rails.logger.error "=" * 80
  end
else
  Rails.logger.info "Cloudinary: Skipping configuration in #{Rails.env} environment (development/test)"
end
