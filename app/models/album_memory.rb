# frozen_string_literal: true

class AlbumMemory < ApplicationRecord
  belongs_to :album
  belongs_to :memory

  validates :album_id, uniqueness: { scope: :memory_id }
end
