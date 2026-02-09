class Reaction < ApplicationRecord
  belongs_to :memory

  EMOJIS = ['❤️', '😍', '😂', '😢', '🥰', '👏'].freeze

  validates :emoji, inclusion: { in: EMOJIS }
  validates :emoji, uniqueness: { scope: :memory_id }
  validates :count, numericality: { greater_than_or_equal_to: 0 }

  scope :for_memory, ->(memory_id) { where(memory_id: memory_id) }
end
