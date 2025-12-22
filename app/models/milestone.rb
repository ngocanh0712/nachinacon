# frozen_string_literal: true

class Milestone < ApplicationRecord
  has_one_attached :photo

  # Predefined milestones for baby (0-3 years)
  MILESTONE_TYPES = {
    'first_smile' => { name: 'Nụ cười đầu tiên', icon: 'smile' },
    'first_laugh' => { name: 'Tiếng cười đầu tiên', icon: 'laugh' },
    'first_tooth' => { name: 'Chiếc răng đầu tiên', icon: 'tooth' },
    'first_word' => { name: 'Từ đầu tiên', icon: 'chat' },
    'first_crawl' => { name: 'Bò lần đầu', icon: 'baby' },
    'first_step' => { name: 'Bước đi đầu tiên', icon: 'footprints' },
    'first_food' => { name: 'Ăn dặm đầu tiên', icon: 'utensils' },
    'first_birthday' => { name: 'Sinh nhật 1 tuổi', icon: 'cake' },
    'second_birthday' => { name: 'Sinh nhật 2 tuổi', icon: 'cake' },
    'third_birthday' => { name: 'Sinh nhật 3 tuổi', icon: 'cake' },
    'custom' => { name: 'Mốc tùy chỉnh', icon: 'star' }
  }.freeze

  validates :name, presence: true
  validates :milestone_type, inclusion: { in: MILESTONE_TYPES.keys }

  scope :achieved, -> { where.not(achieved_at: nil).order(achieved_at: :asc) }
  scope :pending, -> { where(achieved_at: nil) }
  scope :recent, -> { achieved.order(achieved_at: :desc) }

  def achieved?
    achieved_at.present?
  end

  def icon_name
    MILESTONE_TYPES.dig(milestone_type, :icon) || 'star'
  end
end
