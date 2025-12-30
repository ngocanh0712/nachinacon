# frozen_string_literal: true

# Cloudinary configuration for Active Storage
# https://cloudinary.com/documentation/rails_activestorage

# Only configure in production (Railway will have env vars set)
if Rails.env.production?
  # Cloudinary prefers CLOUDINARY_URL format
  if ENV['CLOUDINARY_URL'].present?
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
    Rails.logger.error "Missing Cloudinary credentials. Please set ONE of:"
    Rails.logger.error ""
    Rails.logger.error "Option 1 (Recommended):"
    Rails.logger.error "  CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name"
    Rails.logger.error ""
    Rails.logger.error "Option 2:"
    Rails.logger.error "  CLOUDINARY_CLOUD_NAME=your_cloud_name"
    Rails.logger.error "  CLOUDINARY_API_KEY=your_api_key"
    Rails.logger.error "  CLOUDINARY_API_SECRET=your_api_secret"
    Rails.logger.error ""
    Rails.logger.error "Current environment variables:"
    Rails.logger.error "  CLOUDINARY_URL: #{ENV['CLOUDINARY_URL'].present? ? 'SET' : 'MISSING'}"
    Rails.logger.error "  CLOUDINARY_CLOUD_NAME: #{ENV['CLOUDINARY_CLOUD_NAME'].present? ? ENV['CLOUDINARY_CLOUD_NAME'] : 'MISSING'}"
    Rails.logger.error "  CLOUDINARY_API_KEY: #{ENV['CLOUDINARY_API_KEY'].present? ? 'SET' : 'MISSING'}"
    Rails.logger.error "  CLOUDINARY_API_SECRET: #{ENV['CLOUDINARY_API_SECRET'].present? ? 'SET' : 'MISSING'}"
    Rails.logger.error "=" * 80

    # Don't raise error, just warn - this allows app to start and show logs
  end

  # Verify configuration loaded
  if Cloudinary.config.cloud_name.present? && Cloudinary.config.api_key.present?
    Rails.logger.info "✅ Cloudinary configured successfully"
    Rails.logger.info "   Cloud Name: #{Cloudinary.config.cloud_name}"
    Rails.logger.info "   API Key: #{Cloudinary.config.api_key[0..5]}..."
  else
    Rails.logger.error "❌ Cloudinary configuration incomplete or missing"
  end
else
  Rails.logger.info "Cloudinary: Skipping configuration in #{Rails.env} environment"
end
