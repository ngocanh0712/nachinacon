# frozen_string_literal: true

namespace :cloudinary do
  desc "Test Cloudinary configuration"
  task test: :environment do
    puts "\n" + "=" * 80
    puts "CLOUDINARY CONFIGURATION TEST"
    puts "=" * 80
    puts "\n1. Environment Variables Status:"
    puts "   CLOUDINARY_URL: #{ENV['CLOUDINARY_URL'].present? ? 'SET ✓' : 'MISSING ✗'}"
    if ENV['CLOUDINARY_URL'].present?
      puts "   Value: #{ENV['CLOUDINARY_URL'][0..20]}..."
    end

    puts "\n   CLOUDINARY_CLOUD_NAME: #{ENV['CLOUDINARY_CLOUD_NAME'].present? ? ENV['CLOUDINARY_CLOUD_NAME'] + ' ✓' : 'MISSING ✗'}"
    puts "   CLOUDINARY_API_KEY: #{ENV['CLOUDINARY_API_KEY'].present? ? ENV['CLOUDINARY_API_KEY'][0..5] + '... ✓' : 'MISSING ✗'}"
    puts "   CLOUDINARY_API_SECRET: #{ENV['CLOUDINARY_API_SECRET'].present? ? ENV['CLOUDINARY_API_SECRET'][0..5] + '... ✓' : 'MISSING ✗'}"

    puts "\n2. Cloudinary Gem Configuration:"
    puts "   Cloud Name: #{Cloudinary.config.cloud_name.present? ? Cloudinary.config.cloud_name + ' ✓' : 'NOT SET ✗'}"
    puts "   API Key: #{Cloudinary.config.api_key.present? ? Cloudinary.config.api_key[0..5] + '... ✓' : 'NOT SET ✗'}"
    puts "   API Secret: #{Cloudinary.config.api_secret.present? ? '***... ✓' : 'NOT SET ✗'}"

    puts "\n3. Active Storage Configuration:"
    puts "   Service: #{Rails.configuration.active_storage.service}"

    begin
      service_config = Rails.configuration.active_storage.configurations[:cloudinary]
      if service_config
        puts "   Storage Config:"
        puts "     - cloud_name: #{service_config['cloud_name'].present? ? service_config['cloud_name'] + ' ✓' : 'MISSING ✗'}"
        puts "     - api_key: #{service_config['api_key'].present? ? service_config['api_key'][0..5] + '... ✓' : 'MISSING ✗'}"
        puts "     - api_secret: #{service_config['api_secret'].present? ? '***... ✓' : 'MISSING ✗'}"
      else
        puts "   Storage Config: NOT FOUND ✗"
      end
    rescue => e
      puts "   Storage Config: ERROR - #{e.message}"
    end

    puts "\n4. Configuration Test:"

    if Cloudinary.config.cloud_name.blank? || Cloudinary.config.api_key.blank? || Cloudinary.config.api_secret.blank?
      puts "   ✗ FAILED - Cloudinary is not configured properly"
      puts "\n5. Required Actions:"
      puts "   Go to Railway Dashboard > Variables and add:"
      puts "   CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name"
      puts "\n   Get this value from Cloudinary Dashboard > API Environment variable"
      puts "=" * 80
      exit 1
    end

    # Test actual connection
    begin
      puts "   Testing connection to Cloudinary..."
      response = Cloudinary::Api.ping
      puts "   ✓ SUCCESS - Connection to Cloudinary works!"
      puts "   Response: #{response.inspect}"
    rescue => e
      puts "   ✗ FAILED - Cannot connect to Cloudinary"
      puts "   Error: #{e.message}"
      puts "   This usually means credentials are incorrect"
      exit 1
    end

    puts "\n" + "=" * 80
    puts "✅ ALL TESTS PASSED - Cloudinary is configured correctly!"
    puts "=" * 80 + "\n"
  end

  desc "Show Cloudinary configuration (safe version - no secrets)"
  task status: :environment do
    puts "\nCloudinary Status:"
    puts "  Environment: #{Rails.env}"
    puts "  Service: #{Rails.configuration.active_storage.service}"
    puts "  Cloud Name: #{Cloudinary.config.cloud_name || 'NOT SET'}"
    puts "  API Key: #{Cloudinary.config.api_key.present? ? Cloudinary.config.api_key[0..8] + '...' : 'NOT SET'}"
    puts "  Configured: #{Cloudinary.config.cloud_name.present? && Cloudinary.config.api_key.present? ? 'YES ✓' : 'NO ✗'}"
    puts ""
  end
end
