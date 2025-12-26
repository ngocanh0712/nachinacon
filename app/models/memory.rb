# frozen_string_literal: true

class Memory < ApplicationRecord
  has_one_attached :media
  has_many :album_memories, dependent: :destroy
  has_many :albums, through: :album_memories
  has_many :memory_tags, dependent: :destroy
  has_many :tags, through: :memory_tags

  # Age groups for baby memories
  AGE_GROUPS = [
    ['0-3 tháng', '0-3m'],
    ['3-6 tháng', '3-6m'],
    ['6-12 tháng', '6-12m'],
    ['1-2 tuổi', '1-2y'],
    ['2-3 tuổi', '2-3y']
  ].freeze

  MEMORY_TYPES = %w[photo video].freeze

  validates :title, presence: true
  validates :taken_at, presence: true
  validates :memory_type, inclusion: { in: MEMORY_TYPES }
  validates :age_group, inclusion: { in: AGE_GROUPS.map(&:last) }

  scope :photos, -> { where(memory_type: 'photo') }
  scope :videos, -> { where(memory_type: 'video') }
  scope :by_age_group, ->(group) { where(age_group: group) }
  scope :recent, -> { order(taken_at: :desc) }
  scope :chronological, -> { order(taken_at: :asc) }

  def photo?
    memory_type == 'photo'
  end

  def video?
    memory_type == 'video'
  end

  # Unified method to get image URL (prioritize image_path over Active Storage)
  def display_image_url
    return image_path if image_path.present?
    return nil unless media.attached?

    Rails.application.routes.url_helpers.rails_blob_path(media, only_path: true)
  end

  # Check if memory has any image
  def has_image?
    image_path.present? || media.attached?
  end
end
