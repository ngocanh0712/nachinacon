# frozen_string_literal: true

class Recipe < ApplicationRecord
  # Danh mục ẩm thực
  CATEGORIES = {
    'breakfast'   => 'Bữa sáng',
    'lunch_dinner' => 'Bữa trưa & tối',
    'soup'        => 'Canh & súp',
    'snack'       => 'Ăn vặt & tráng miệng',
    'baby_food'   => 'Ăn dặm cho bé',
    'quick'       => 'Nấu nhanh'
  }.freeze

  CATEGORY_ICONS = {
    'breakfast'    => '🍳',
    'lunch_dinner' => '🍽️',
    'soup'         => '🍲',
    'snack'        => '🍡',
    'baby_food'    => '👶',
    'quick'        => '⚡'
  }.freeze

  CATEGORY_COLORS = {
    'breakfast'    => '#F97316',
    'lunch_dinner' => '#DC2626',
    'soup'         => '#2563EB',
    'snack'        => '#D97706',
    'baby_food'    => '#EC4899',
    'quick'        => '#10B981'
  }.freeze

  validates :title, presence: true
  validates :content, presence: true
  validates :category, inclusion: { in: CATEGORIES.keys }

  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :recent, -> { order(created_at: :desc) }

  def category_label
    CATEGORIES[category] || category
  end

  def category_icon
    CATEGORY_ICONS[category] || '🍽️'
  end

  def category_color
    CATEGORY_COLORS[category] || '#6B7280'
  end
end
