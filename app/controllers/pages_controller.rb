# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @recent_memories = Memory.recent.limit(8)
    @achieved_milestones = Milestone.achieved.limit(6)
    @memory_count = Memory.count
    @milestone_count = Milestone.achieved.count
    @album_count = Album.count
  end

  def timeline
    @age_group = params[:age_group]
    @memories = if @age_group.present?
                  Memory.by_age_group(@age_group).recent
                else
                  Memory.recent
                end
    @age_groups = Memory::AGE_GROUPS
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
end
