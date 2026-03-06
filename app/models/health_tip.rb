# frozen_string_literal: true

class HealthTip < ApplicationRecord
  # Danh mục chăm sóc sức khoẻ mẹ và bé
  CATEGORIES = {
    'nutrition_mom' => 'Dinh dưỡng cho mẹ',
    'nutrition_baby' => 'Dinh dưỡng cho bé',
    'newborn_care' => 'Chăm sóc trẻ sơ sinh',
    'postpartum' => 'Chăm sóc mẹ sau sinh',
    'development' => 'Phát triển của bé',
    'common_illness' => 'Bệnh thường gặp',
    'sleep' => 'Giấc ngủ',
    'vaccination' => 'Tiêm chủng',
    'general' => 'Kiến thức chung'
  }.freeze

  CATEGORY_ICONS = {
    'nutrition_mom' => '🍜',
    'nutrition_baby' => '🍼',
    'newborn_care' => '👶',
    'postpartum' => '🤱',
    'development' => '📈',
    'common_illness' => '🏥',
    'sleep' => '😴',
    'vaccination' => '💉',
    'general' => '📋'
  }.freeze

  CATEGORY_COLORS = {
    'nutrition_mom' => '#F97316',
    'nutrition_baby' => '#3B82F6',
    'newborn_care' => '#EC4899',
    'postpartum' => '#E8B0B0',
    'development' => '#10B981',
    'common_illness' => '#EF4444',
    'sleep' => '#8B5CF6',
    'vaccination' => '#06B6D4',
    'general' => '#6B7280'
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
    CATEGORY_ICONS[category] || '📋'
  end

  def category_color
    CATEGORY_COLORS[category] || '#6B7280'
  end
end
