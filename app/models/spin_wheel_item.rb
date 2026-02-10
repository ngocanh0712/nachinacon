# frozen_string_literal: true

class SpinWheelItem < ApplicationRecord
  CATEGORIES = %w[reward punishment challenge interaction].freeze
  CATEGORY_LABELS = {
    'reward' => 'Thưởng',
    'punishment' => 'Phạt',
    'challenge' => 'Thử thách',
    'interaction' => 'Tương tác'
  }.freeze

  validates :label, presence: true
  validates :emoji, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :color, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, id: :asc) }

  # Default items seeded on first use
  DEFAULT_ITEMS = [
    { emoji: '🧹', label: 'Rửa bát 1 bữa', category: 'punishment', color: '#F2C2C2' },
    { emoji: '💰', label: 'Được lì xì', category: 'reward', color: '#FEF3C7' },
    { emoji: '🎤', label: 'Hát 1 bài', category: 'challenge', color: '#DBEAFE' },
    { emoji: '💃', label: 'Nhảy 1 điệu', category: 'challenge', color: '#EDE9FE' },
    { emoji: '🧧', label: 'Lì xì người bên cạnh', category: 'interaction', color: '#FFEDD5' },
    { emoji: '📸', label: 'Chụp ảnh dáng hài', category: 'challenge', color: '#C1DDD8' },
    { emoji: '🍵', label: 'Pha trà cho cả nhà', category: 'punishment', color: '#C0DFD0' },
    { emoji: '🎁', label: 'Nhận quà bí ẩn', category: 'reward', color: '#D1FAE5' },
    { emoji: '🤗', label: 'Ôm 1 người', category: 'interaction', color: '#FCE7F3' },
    { emoji: '🤣', label: 'Kể chuyện cười', category: 'challenge', color: '#E8B0B0' }
  ].freeze

  # Ensure items exist, seed defaults if empty
  def self.ensure_items!
    return if exists?

    DEFAULT_ITEMS.each_with_index do |item, i|
      create!(item.merge(position: i, active: true))
    end
  end
end
