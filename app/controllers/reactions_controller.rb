# frozen_string_literal: true

class ReactionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def index
    memory = Memory.find(params[:id])
    reactions = memory.reactions.pluck(:emoji, :count).to_h
    render json: { reactions: reactions }
  end

  def create
    memory = Memory.find(params[:id])
    emoji = params[:emoji]

    unless Reaction::EMOJIS.include?(emoji)
      return render json: { error: 'Invalid emoji' }, status: :unprocessable_entity
    end

    reaction = memory.reactions.find_or_initialize_by(emoji: emoji)
    reaction.count += 1

    if reaction.save
      render json: {
        emoji: reaction.emoji,
        count: reaction.count,
        total: memory.reactions.sum(:count)
      }
    else
      render json: { error: reaction.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
