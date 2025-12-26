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
        'hero_subtitle' => SiteSetting.get('hero_subtitle')
      }
    end

    def update
      # Update each setting
      params[:settings]&.each do |key, value|
        next if value.blank?

        type = key.include?('date') ? 'date' : 'string'
        SiteSetting.set(key, value, type)
      end

      redirect_to admin_settings_path, notice: 'Đã cập nhật cài đặt thành công!'
    rescue StandardError => e
      redirect_to admin_settings_path, alert: "Lỗi: #{e.message}"
    end
  end
end
