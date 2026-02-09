# frozen_string_literal: true

class SpinWheelItem < ApplicationRecord
  CATEGORIES = %w[reward punishment challenge interaction].freeze
  CATEGORY_LABELS = {
    'reward' => 'Thuong',
    'punishment' => 'Phat',
    'challenge' => 'Thu thach',
    'interaction' => 'Tuong tac'
  }.freeze

  validates :label, presence: true
  validates :emoji, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :color, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, id: :asc) }

  # Default items seeded on first use
  DEFAULT_ITEMS = [
    { emoji: '🧹', label: 'Rua bat 1 bua', category: 'punishment', color: '#F2C2C2' },
    { emoji: '💰', label: 'Duoc li xi', category: 'reward', color: '#FEF3C7' },
    { emoji: '🎤', label: 'Hat 1 bai', category: 'challenge', color: '#DBEAFE' },
    { emoji: '💃', label: 'Nhay 1 dieu', category: 'challenge', color: '#EDE9FE' },
    { emoji: '🧧', label: 'Li xi nguoi ben canh', category: 'interaction', color: '#FFEDD5' },
    { emoji: '📸', label: 'Chup anh dang hai', category: 'challenge', color: '#C1DDD8' },
    { emoji: '🍵', label: 'Pha tra cho ca nha', category: 'punishment', color: '#C0DFD0' },
    { emoji: '🎁', label: 'Nhan qua bi an', category: 'reward', color: '#D1FAE5' },
    { emoji: '🤗', label: 'Om 1 nguoi', category: 'interaction', color: '#FCE7F3' },
    { emoji: '🤣', label: 'Ke chuyen cuoi', category: 'challenge', color: '#E8B0B0' }
  ].freeze

  # Ensure items exist, seed defaults if empty
  def self.ensure_items!
    return if exists?

    DEFAULT_ITEMS.each_with_index do |item, i|
      create!(item.merge(position: i, active: true))
    end
  end
end
