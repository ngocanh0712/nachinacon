# frozen_string_literal: true

class Album < ApplicationRecord
  has_many :album_memories, dependent: :destroy
  has_many :memories, through: :album_memories
  has_one_attached :cover_photo

  validates :name, presence: true

  scope :with_memories, -> { includes(:memories) }
  scope :recent, -> { order(created_at: :desc) }

  def memory_count
    memories.count
  end
end
