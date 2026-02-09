# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:spin]

  def home
    @recent_memories = Memory.includes(:tags, :reactions).recent.limit(8)
    @achieved_milestones = Milestone.achieved.limit(3)
    @pending_milestones = Milestone.pending.limit(3)

    # Stats
    @memory_count = Memory.count
    @milestone_count = Milestone.achieved.count
    @album_count = Album.count
    @tag_count = Tag.count

    # Featured memory (random with image)
    @featured_memory = Memory.where.not(image_path: nil).order('RAND()').first ||
                       Memory.where('media IS NOT NULL').order('RAND()').first

    # Popular tags (with memory count)
    @popular_tags = Tag.joins(:memories)
                       .select('tags.*, COUNT(memories.id) as memory_count')
                       .group('tags.id')
                       .order('memory_count DESC')
                       .limit(8)

    # Recent albums
    @recent_albums = Album.with_memories.recent.limit(4)

    # Days since birth
    birth_date = SiteSetting.baby_birth_date
    @days_old = (Date.today - birth_date).to_i

    # Memory Box - "On this day" memories from previous years
    @memory_box = Memory.includes(:tags, :reactions).on_this_day.order('RAND()').limit(4)
  end

  def timeline
    @age_group = params[:age_group]
    memories = if @age_group.present?
                 Memory.includes(:tags, :reactions).by_age_group(@age_group).recent
               else
                 Memory.includes(:tags, :reactions).recent
               end
    @age_groups = Memory::AGE_GROUPS
    @pagy, @memories = pagy(memories, items: 12)
  end

  def milestones
    @achieved = Milestone.achieved
    @pending = Milestone.pending
  end

  def albums
    @albums = Album.with_memories.recent
  end

  def album
    @album = Album.find(params[:id])
    @memories = @album.memories.recent
  end

  def memory
    @memory = Memory.includes(:tags).find(params[:id])
  end

  def games
  end

  def then_vs_now
    @age_groups = Memory::AGE_GROUPS
    youngest_group = params[:before] || '0-3m'
    recent_group = params[:after] || '2-3y'

    @before_memory = Memory.photos.by_age_group(youngest_group)
                          .where.not(image_path: [nil, ''])
                          .order('RAND()').first

    @after_memory = Memory.photos.by_age_group(recent_group)
                         .where.not(image_path: [nil, ''])
                         .order('RAND()').first

    @selected_before = youngest_group
    @selected_after = recent_group
  end

  def spin_wheel
    SpinWheelItem.ensure_items!
    @items = SpinWheelItem.active.ordered.limit(10)
  end

  def spin
    SpinWheelItem.ensure_items!
    item = SpinWheelItem.active.order('RAND()').first
    if item
      render json: {
        id: item.id,
        emoji: item.emoji,
        label: item.label,
        category: item.category,
        category_label: SpinWheelItem::CATEGORY_LABELS[item.category],
        color: item.color
      }
    else
      render json: { error: 'No items found' }, status: :not_found
    end
  end

  def search
    @query = params[:q]
    @age_group = params[:age_group]

    if @query.present? || @age_group.present?
      @memories = Memory.includes(:tags).recent
      @memories = @memories.where("title LIKE ? OR caption LIKE ?", "%#{@query}%", "%#{@query}%") if @query.present?
      @memories = @memories.where(age_group: @age_group) if @age_group.present?
      @pagy, @memories = pagy(@memories, items: 12)
    else
      @memories = []
    end

    @age_groups = Memory::AGE_GROUPS
  end
end
