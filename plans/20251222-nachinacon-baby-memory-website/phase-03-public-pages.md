# Phase 3: Public Pages

## Context
- Parent plan: [plan.md](./plan.md)
- Dependencies: Phase 1, 2

## Overview
- **Priority:** High
- **Status:** Pending
- **Description:** Hoàn thiện các trang public: Home, Timeline, Milestones, Albums

## Key Insights
- Home page đã có layout cơ bản
- Timeline cần filter theo age group
- Milestones cần design cards đẹp
- Albums là trang mới

## Requirements

### Functional
- Home: Hero, recent memories, achieved milestones
- Timeline: Filter by age group, grid gallery
- Milestones: Timeline vertical, cards với icons
- Albums: Grid albums, click vào xem ảnh

### Non-functional
- Responsive mobile-first
- Lazy loading images
- Smooth transitions

## Architecture

### Routes (already defined)
```ruby
root 'pages#home'
get 'timeline', to: 'pages#timeline'
get 'milestones', to: 'pages#milestones'
get 'gallery', to: 'pages#gallery'  # rename to albums
```

### Page Structure
```
Home
├── Hero section (intro bé)
├── Quick stats
├── Recent memories grid
└── Achieved milestones badges

Timeline
├── Age group tabs/filter
├── Memory grid by group
└── Lazy load more

Milestones
├── Vertical timeline
├── Milestone cards với icon
└── Photo thumbnails

Albums
├── Album cards grid
├── Click → album detail
└── Lightbox for photos
```

## Related Code Files

### Create
- `app/views/pages/albums.html.erb`
- `app/views/pages/_memory_card.html.erb` (partial)
- `app/views/pages/_milestone_card.html.erb` (partial)
- `app/views/pages/_album_card.html.erb` (partial)

### Modify
- `config/routes.rb` - add albums route
- `app/controllers/pages_controller.rb` - add albums action
- `app/views/pages/home.html.erb` - enhance UI
- `app/views/pages/timeline.html.erb` - filter + grid
- `app/views/pages/milestones.html.erb` - vertical timeline
- `app/views/layouts/application.html.erb` - add Albums nav

## Implementation Steps

### 1. Update routes
```ruby
get 'albums', to: 'pages#albums'
get 'albums/:id', to: 'pages#album', as: :album_detail
```

### 2. Update PagesController
```ruby
class PagesController < ApplicationController
  def home
    @recent_memories = Memory.recent.limit(6)
    @achieved_milestones = Milestone.achieved.limit(5)
    @memory_count = Memory.count
    @milestone_count = Milestone.achieved.count
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
```

### 3. Create Timeline view with filter
```erb
<!-- Age group filter tabs -->
<div class="flex flex-wrap gap-2 mb-8">
  <%= link_to "Tất cả", timeline_path,
      class: "px-4 py-2 rounded-full #{@age_group.nil? ? 'bg-primary' : 'bg-white'}" %>
  <% @age_groups.each do |label, value| %>
    <%= link_to label, timeline_path(age_group: value),
        class: "px-4 py-2 rounded-full #{@age_group == value ? 'bg-primary' : 'bg-white'}" %>
  <% end %>
</div>

<!-- Memory grid -->
<div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
  <% @memories.each do |memory| %>
    <%= render 'memory_card', memory: memory %>
  <% end %>
</div>
```

### 4. Create Milestones vertical timeline
```erb
<div class="relative">
  <!-- Vertical line -->
  <div class="absolute left-6 top-0 bottom-0 w-0.5 bg-primary"></div>

  <% @achieved.each do |milestone| %>
    <div class="relative pl-16 pb-8">
      <!-- Icon circle -->
      <div class="absolute left-3 w-6 h-6 rounded-full bg-secondary"></div>
      <!-- Card -->
      <%= render 'milestone_card', milestone: milestone %>
    </div>
  <% end %>
</div>
```

### 5. Create Albums grid page
```erb
<section class="py-12 px-4">
  <h1 class="font-heading text-3xl mb-8">Albums</h1>

  <div class="grid grid-cols-2 md:grid-cols-3 gap-6">
    <% @albums.each do |album| %>
      <%= render 'album_card', album: album %>
    <% end %>
  </div>
</section>
```

### 6. Create partials for reusability

### 7. Update navigation to include Albums

## Todo List
- [ ] Update routes for albums
- [ ] Update PagesController with all actions
- [ ] Create _memory_card partial
- [ ] Create _milestone_card partial
- [ ] Create _album_card partial
- [ ] Enhance home.html.erb
- [ ] Create timeline.html.erb with filter
- [ ] Create milestones.html.erb vertical timeline
- [ ] Create albums.html.erb
- [ ] Create album detail page
- [ ] Update navigation

## Success Criteria
- [ ] Home hiển thị đúng stats và recent items
- [ ] Timeline filter by age group hoạt động
- [ ] Milestones hiển thị timeline đẹp
- [ ] Albums grid và detail hoạt động
- [ ] Navigation có đủ links

## Risk Assessment
- **Medium:** Nhiều view files
- Cần test trên mobile

## Security Considerations
- Public pages, không cần auth
- Image variants để tránh large files

## Next Steps
→ Phase 4: UI Enhancement
