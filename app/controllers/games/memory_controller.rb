# frozen_string_literal: true

module Games
  class MemoryController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:start, :complete]

    DIFFICULTIES = {
      'easy' => 6,
      'medium' => 8,
      'hard' => 10
    }.freeze

    def index
      @best_scores = GameSession.memory_games.best_scores.limit(5)
    end

    def start
      difficulty = params[:difficulty] || 'easy'
      pairs = DIFFICULTIES[difficulty] || 6

      memories = Memory.photos.where.not(image_path: [nil, ''])
                       .order('RAND()').limit(pairs)

      cards = memories.flat_map do |m|
        [
          { id: "#{m.id}_a", memory_id: m.id, image_url: m.image_path, title: m.title },
          { id: "#{m.id}_b", memory_id: m.id, image_url: m.image_path, title: m.title }
        ]
      end.shuffle

      render json: {
        cards: cards,
        pairs: memories.count,
        difficulty: difficulty
      }
    end

    def complete
      score = params[:score].to_i
      moves = params[:moves].to_i
      time_seconds = params[:time_seconds].to_i
      difficulty = params[:difficulty] || 'easy'

      game_session = GameSession.create!(
        game_type: 'memory_game',
        score: score,
        moves: moves,
        time_seconds: time_seconds,
        difficulty: difficulty,
        completed_at: Time.current
      )

      render json: {
        score: score,
        moves: moves,
        time_seconds: time_seconds,
        difficulty: difficulty
      }
    end
  end
end
