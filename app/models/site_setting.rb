# Site-wide configuration settings stored in database
# Allows admin to configure baby details and other site settings without code changes
class SiteSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Default settings for the application
  DEFAULTS = {
    'baby_name' => 'NaChiNaCon',
    'baby_nickname' => 'Nacon',
    'baby_birth_date' => '2024-09-14',
    'site_title' => 'NaChiNaCon - Baby Memory Keepsake',
    'hero_title' => 'Nhật ký của',
    'hero_subtitle' => 'Chào mừng đến với'
  }.freeze

  # Get setting value by key, returns default if not found
  def self.get(key)
    setting = find_by(key: key)
    return setting&.typed_value if setting
    DEFAULTS[key.to_s]
  end

  # Set setting value with optional type
  def self.set(key, value, type = 'string')
    setting = find_or_initialize_by(key: key)
    setting.value = value.to_s
    setting.value_type = type
    setting.save!
  end

  # Get baby's birth date as Date object
  def self.baby_birth_date
    date_str = get('baby_birth_date')
    Date.parse(date_str) rescue Date.new(2024, 9, 14)
  end

  # Calculate baby's age in months
  def self.baby_age_in_months
    birth_date = baby_birth_date
    today = Date.today

    months = (today.year - birth_date.year) * 12 + (today.month - birth_date.month)
    months -= 1 if today.day < birth_date.day

    months
  end

  # Convert stored value to appropriate type
  def typed_value
    case value_type
    when 'date'
      Date.parse(value) rescue nil
    when 'integer'
      value.to_i
    when 'boolean'
      value == 'true'
    else
      value
    end
  end
end
