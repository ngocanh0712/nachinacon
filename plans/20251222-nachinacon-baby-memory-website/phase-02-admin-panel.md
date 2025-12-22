# Phase 2: Admin Panel

## Context
- Parent plan: [plan.md](./plan.md)
- Dependencies: Phase 1 (Album model)

## Overview
- **Priority:** High
- **Status:** Pending
- **Description:** CRUD Albums, cải thiện UI admin panel, thêm chức năng gán ảnh vào album

## Key Insights
- Admin layout đã có (`app/views/layouts/admin.html.erb`)
- Memory CRUD đã có, cần thêm album selection
- Milestone CRUD đã có
- Dashboard cần thống kê

## Requirements

### Functional
- CRUD Albums (create, read, update, delete)
- Gán/bỏ Memory khỏi Album khi edit Memory
- Dashboard hiển thị thống kê
- Upload cover photo cho Album

### Non-functional
- UI consistent với public pages (pastel theme)
- Form validation với error messages
- Flash messages cho actions

## Architecture

### Routes Update
```ruby
namespace :admin do
  root 'dashboard#index'
  resources :memories
  resources :milestones
  resources :albums  # NEW
end
```

### Controller Flow
```
Admin::AlbumsController
├── index   → list all albums
├── new     → form tạo album
├── create  → save album
├── edit    → form edit
├── update  → save changes
└── destroy → delete album
```

## Related Code Files

### Create
- `app/controllers/admin/albums_controller.rb`
- `app/views/admin/albums/index.html.erb`
- `app/views/admin/albums/_form.html.erb`
- `app/views/admin/albums/new.html.erb`
- `app/views/admin/albums/edit.html.erb`

### Modify
- `config/routes.rb` - thêm albums resource
- `app/views/admin/memories/_form.html.erb` - thêm album checkboxes
- `app/controllers/admin/memories_controller.rb` - permit album_ids
- `app/views/admin/dashboard/index.html.erb` - thêm album stats
- `app/views/layouts/admin.html.erb` - thêm Albums link

## Implementation Steps

### 1. Update routes
```ruby
# config/routes.rb - trong namespace :admin
resources :albums
```

### 2. Create AlbumsController
```ruby
# app/controllers/admin/albums_controller.rb
module Admin
  class AlbumsController < BaseController
    before_action :set_album, only: [:edit, :update, :destroy]

    def index
      @albums = Album.with_memories.recent
    end

    def new
      @album = Album.new
    end

    def create
      @album = Album.new(album_params)
      if @album.save
        redirect_to admin_albums_path, notice: 'Album đã được tạo.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @album.update(album_params)
        redirect_to admin_albums_path, notice: 'Album đã được cập nhật.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @album.destroy
      redirect_to admin_albums_path, notice: 'Album đã được xóa.'
    end

    private

    def set_album
      @album = Album.find(params[:id])
    end

    def album_params
      params.require(:album).permit(:name, :description, :cover_photo)
    end
  end
end
```

### 3. Create Album views (index, form, new, edit)

### 4. Update Memory form - thêm album checkboxes
```erb
<!-- Add to memories/_form.html.erb -->
<div class="mb-4">
  <label class="block text-sm font-medium text-gray-700 mb-2">Albums</label>
  <div class="flex flex-wrap gap-2">
    <% Album.all.each do |album| %>
      <label class="inline-flex items-center">
        <%= check_box_tag 'memory[album_ids][]', album.id,
            @memory.album_ids.include?(album.id),
            class: "rounded" %>
        <span class="ml-2 text-sm"><%= album.name %></span>
      </label>
    <% end %>
  </div>
</div>
```

### 5. Update MemoriesController - permit album_ids
```ruby
def memory_params
  params.require(:memory).permit(:title, :caption, :taken_at,
    :age_group, :memory_type, :media, album_ids: [])
end
```

### 6. Update Dashboard stats
```erb
<!-- Add to dashboard/index.html.erb -->
<div class="stat-card">
  <span class="text-2xl font-bold"><%= Album.count %></span>
  <span class="text-gray-500">Albums</span>
</div>
```

### 7. Update admin layout - thêm Albums nav link

## Todo List
- [ ] Add albums route
- [ ] Create AlbumsController
- [ ] Create albums/index.html.erb
- [ ] Create albums/_form.html.erb
- [ ] Create albums/new.html.erb
- [ ] Create albums/edit.html.erb
- [ ] Update memories form with album checkboxes
- [ ] Update MemoriesController permit params
- [ ] Update dashboard stats
- [ ] Update admin nav with Albums link

## Success Criteria
- [ ] Tạo/sửa/xóa Album thành công
- [ ] Gán Memory vào Album hoạt động
- [ ] Dashboard hiển thị đúng số liệu
- [ ] Flash messages hiển thị đúng

## Risk Assessment
- **Low risk:** Standard Rails CRUD
- Cẩn thận với album_ids array permit

## Security Considerations
- Strong parameters cho mass assignment
- Admin authentication đã có sẵn

## Next Steps
→ Phase 3: Public Pages
