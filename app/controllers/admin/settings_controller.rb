# Admin controller for managing site-wide settings
module Admin
  class SettingsController < BaseController
    def index
      @settings = {
        'baby_name' => SiteSetting.get('baby_name'),
        'baby_nickname' => SiteSetting.get('baby_nickname'),
        'baby_birth_date' => SiteSetting.get('baby_birth_date'),
        'site_title' => SiteSetting.get('site_title'),
        'hero_title' => SiteSetting.get('hero_title'),
        'hero_subtitle' => SiteSetting.get('hero_subtitle'),
        'gemini_api_key' => SiteSetting.get('gemini_api_key')
      }
    end

    def update
      # Update each setting
      params[:settings]&.each do |key, value|
        # Allow clearing API key; skip blank for other fields
        next if value.blank? && key != 'gemini_api_key'

        type = key.include?('date') ? 'date' : 'string'
        SiteSetting.set(key, value, type)
      end

      redirect_to admin_settings_path, notice: 'Đã cập nhật cài đặt thành công!'
    rescue StandardError => e
      redirect_to admin_settings_path, alert: "Lỗi: #{e.message}"
    end
  end
end
