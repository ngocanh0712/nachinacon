# frozen_string_literal: true

class GrowthRecord < ApplicationRecord
  validates :recorded_on, presence: true, uniqueness: true
  validates :height_cm, numericality: { greater_than: 0 }, allow_nil: true
  validates :weight_kg, numericality: { greater_than: 0 }, allow_nil: true
  validates :head_cm, numericality: { greater_than: 0 }, allow_nil: true
  validate :at_least_one_measurement

  scope :chronological, -> { order(recorded_on: :asc) }
  scope :recent, -> { order(recorded_on: :desc) }

  def age_in_months
    birth_date = SiteSetting.baby_birth_date
    ((recorded_on.year * 12 + recorded_on.month) - (birth_date.year * 12 + birth_date.month))
  end

  private

  def at_least_one_measurement
    if height_cm.blank? && weight_kg.blank? && head_cm.blank?
      errors.add(:base, 'Cần ít nhất một chỉ số (chiều cao, cân nặng, hoặc vòng đầu)')
    end
  end
end
