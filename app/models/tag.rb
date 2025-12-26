# frozen_string_literal: true

# Tags for categorizing memories (e.g., 'Sinh nhật', 'Du lịch', 'Gia đình')
class Tag < ApplicationRecord
  has_many :memory_tags, dependent: :destroy
  has_many :memories, through: :memory_tags

  validates :name, presence: true, uniqueness: true
  validates :color, presence: true

  # Popular tag colors (pastel palette)
  COLORS = [
    '#C1DDD8', # Primary sage
    '#F2C2C2', # Blush pink
    '#C0DFD0', # Mint green
    '#E8B0B0', # Light mauve
    '#D4E4DD', # Pale green
    '#F5D5C0', # Peach
    '#C9E4F5', # Sky blue
    '#E8D4F0'  # Lavender
  ].freeze

  scope :alphabetical, -> { order(:name) }
  scope :popular, -> { joins(:memories).group('tags.id').order('COUNT(memories.id) DESC') }

  # Count memories with this tag
  def memory_count
    memories.count
  end
end
