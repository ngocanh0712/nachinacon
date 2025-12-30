# frozen_string_literal: true

# Cloudinary configuration for Active Storage
# https://cloudinary.com/documentation/rails_activestorage

if Rails.env.production?
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
    config.secure = true
    config.cdn_subdomain = true
  end
end
