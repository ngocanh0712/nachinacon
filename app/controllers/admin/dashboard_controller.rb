# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @total_memories = Memory.count
      @total_photos = Memory.photos.count
      @total_videos = Memory.videos.count
      @total_albums = Album.count
      @achieved_milestones = Milestone.achieved.count
      @pending_milestones = Milestone.pending.count
      @recent_memories = Memory.recent.limit(5)
    end
  end
end
