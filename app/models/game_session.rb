class GameSession < ApplicationRecord
  GAME_TYPES = %w[memory_game guess_age].freeze
  DIFFICULTIES = %w[easy medium hard].freeze

  validates :game_type, inclusion: { in: GAME_TYPES }
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_nil: true

  scope :memory_games, -> { where(game_type: 'memory_game') }
  scope :guess_age_games, -> { where(game_type: 'guess_age') }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :best_scores, -> { completed.order(score: :desc, time_seconds: :asc) }
end
