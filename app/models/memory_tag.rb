# frozen_string_literal: true

# Join model for memories and tags (many-to-many)
class MemoryTag < ApplicationRecord
  belongs_to :memory
  belongs_to :tag

  validates :memory_id, uniqueness: { scope: :tag_id }
end
