# Phase 1: Database & Models

## Context
- Parent plan: [plan.md](./plan.md)
- Dependencies: None (first phase)

## Overview
- **Priority:** High
- **Status:** Pending
- **Description:** Thêm Album model, thiết lập quan hệ many-to-many với Memory

## Key Insights
- Memory model đã có: title, caption, taken_at, age_group, memory_type, media attachment
- Milestone model đã có: name, description, achieved_at, milestone_type, photo attachment
- Cần join table `album_memories` cho many-to-many

## Requirements

### Functional
- Album có name, description, cover_photo
- Memory thuộc nhiều Album (many-to-many)
- Album hiển thị số lượng ảnh

### Non-functional
- Query tối ưu với eager loading
- Index trên foreign keys

## Architecture

### ERD Update
```
Album (new)
├── id
├── name (string, required)
├── description (text)
├── cover_photo (Active Storage)
└── timestamps

AlbumMemory (join table)
├── album_id (FK)
└── memory_id (FK)
```

### Associations
```ruby
# Album
has_many :album_memories
has_many :memories, through: :album_memories
has_one_attached :cover_photo

# Memory (update)
has_many :album_memories
has_many :albums, through: :album_memories
```

## Related Code Files

### Create
- `db/migrate/xxx_create_albums.rb`
- `db/migrate/xxx_create_album_memories.rb`
- `app/models/album.rb`
- `app/models/album_memory.rb`

### Modify
- `app/models/memory.rb` - thêm association

## Implementation Steps

1. Generate Album model
```bash
rails g model Album name:string description:text
```

2. Generate join table
```bash
rails g model AlbumMemory album:references memory:references
```

3. Run migrations
```bash
rails db:migrate
```

4. Update Album model (`app/models/album.rb`)
```ruby
class Album < ApplicationRecord
  has_many :album_memories, dependent: :destroy
  has_many :memories, through: :album_memories
  has_one_attached :cover_photo

  validates :name, presence: true

  scope :with_memories, -> { includes(:memories) }
  scope :recent, -> { order(created_at: :desc) }

  def memory_count
    memories.count
  end
end
```

5. Create AlbumMemory model (`app/models/album_memory.rb`)
```ruby
class AlbumMemory < ApplicationRecord
  belongs_to :album
  belongs_to :memory

  validates :album_id, uniqueness: { scope: :memory_id }
end
```

6. Update Memory model - add associations
```ruby
# Add to app/models/memory.rb
has_many :album_memories, dependent: :destroy
has_many :albums, through: :album_memories
```

## Todo List
- [ ] Generate Album migration
- [ ] Generate AlbumMemory join table
- [ ] Run migrations
- [ ] Create Album model with validations
- [ ] Create AlbumMemory model
- [ ] Update Memory model associations
- [ ] Test associations in rails console

## Success Criteria
- [ ] `rails db:migrate` chạy thành công
- [ ] `Album.create(name: "Test")` hoạt động
- [ ] `memory.albums << album` hoạt động
- [ ] `album.memories` trả về đúng

## Risk Assessment
- **Low risk:** Đơn giản, chỉ thêm model mới
- Không ảnh hưởng code hiện tại

## Security Considerations
- Không có user input trực tiếp
- Validation presence/uniqueness

## Next Steps
→ Phase 2: Admin Panel (CRUD Albums)
