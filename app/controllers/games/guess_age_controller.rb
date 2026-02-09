# frozen_string_literal: true

module Games
  class GuessAgeController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:start, :check_answer, :complete]

    def index
      @best_score = GameSession.guess_age_games.best_scores.first
    end

    def start
      memories = Memory.photos.where.not(image_path: [nil, ''])
                       .order('RAND()').limit(10)

      questions = memories.map do |m|
        correct = m.age_group
        options = Memory::AGE_GROUPS.map(&:last).shuffle

        {
          id: m.id,
          image_url: m.image_path,
          title: m.title,
          correct_answer: correct,
          correct_label: Memory::AGE_GROUPS.find { |_, v| v == correct }&.first,
          options: Memory::AGE_GROUPS.map { |label, value| { label: label, value: value } }.shuffle
        }
      end

      session[:quiz_answers] = {}
      render json: { questions: questions }
    end

    def check_answer
      memory = Memory.find(params[:memory_id])
      answer = params[:answer]
      correct = memory.age_group == answer
      correct_label = Memory::AGE_GROUPS.find { |_, v| v == memory.age_group }&.first

      render json: {
        correct: correct,
        correct_answer: memory.age_group,
        correct_label: correct_label
      }
    end

    def complete
      score = params[:score].to_i
      total = params[:total].to_i
      time_seconds = params[:time_seconds].to_i

      game_session = GameSession.create!(
        game_type: 'guess_age',
        score: score,
        moves: total,
        time_seconds: time_seconds,
        completed_at: Time.current
      )

      # Encouraging messages based on score
      message = case score
                when 9..10 then 'Tuyet voi! Ban hieu Nacon rat ro!'
                when 7..8 then 'Rat gioi! Ban la nguoi quan sat tot!'
                when 5..6 then 'Kha lam! Co gang them nhe!'
                else 'Khong sao, hay thu lai nhe!'
                end

      render json: {
        score: score,
        total: total,
        message: message,
        time_seconds: time_seconds
      }
    end
  end
end
