# frozen_string_literal: true

# Cloudinary configuration for Active Storage
# https://cloudinary.com/documentation/rails_activestorage

# Cloudinary prefers CLOUDINARY_URL format, but we support both
if ENV['CLOUDINARY_URL'].present?
  # CLOUDINARY_URL format: cloudinary://api_key:api_secret@cloud_name
  Rails.logger.info "Cloudinary: Using CLOUDINARY_URL"
  Cloudinary.config_from_url(ENV['CLOUDINARY_URL'])
else
  # Fallback to individual env vars
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
    config.secure = true
    config.cdn_subdomain = true
  end
  Rails.logger.info "Cloudinary: Using individual env vars (cloud_name: #{ENV['CLOUDINARY_CLOUD_NAME']})"
end

Rails.logger.info "Cloudinary configured successfully"
