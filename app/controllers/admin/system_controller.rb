# frozen_string_literal: true

module Admin
  class SystemController < BaseController
    def cloudinary_status
      @env_vars = {
        cloudinary_url: ENV['CLOUDINARY_URL'],
        cloud_name: ENV['CLOUDINARY_CLOUD_NAME'],
        api_key: ENV['CLOUDINARY_API_KEY'],
        api_secret: ENV['CLOUDINARY_API_SECRET']
      }

      @gem_config = {
        cloud_name: Cloudinary.config.cloud_name,
        api_key: Cloudinary.config.api_key,
        api_secret: Cloudinary.config.api_secret&.present? ? '***SET***' : nil
      }

      @active_storage_service = Rails.configuration.active_storage.service

      begin
        @storage_config = Rails.configuration.active_storage.configurations[:cloudinary]
      rescue => e
        @storage_config_error = e.message
      end

      # Test connection
      begin
        if Cloudinary.config.cloud_name.present? && Cloudinary.config.api_key.present?
          @connection_test = Cloudinary::Api.ping
          @connection_status = :success
        else
          @connection_status = :not_configured
        end
      rescue => e
        @connection_status = :error
        @connection_error = e.message
      end
    end
  end
end
