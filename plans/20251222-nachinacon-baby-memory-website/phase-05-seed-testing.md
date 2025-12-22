# Phase 5: Seed Data & Testing

## Context
- Parent plan: [plan.md](./plan.md)
- Dependencies: Phase 1-4

## Overview
- **Priority:** Medium
- **Status:** Pending
- **Description:** Tạo sample data, test thủ công các features

## Key Insights
- Seeds file đã có (`db/seeds.rb`)
- Cần admin account mặc định
- Sample memories với placeholder images
- Sample milestones với dates

## Requirements

### Functional
- Admin account mặc định
- 10-15 sample memories
- 5-8 sample milestones
- 2-3 sample albums

### Non-functional
- Reproducible seeds (clear + create)
- Placeholder images từ placekitten/unsplash

## Architecture

### Seed Data Structure
```ruby
# Order matters for associations
1. Create Admin
2. Create Albums
3. Create Memories (attach to albums)
4. Create Milestones
```

## Related Code Files

### Modify
- `db/seeds.rb`

## Implementation Steps

### 1. Update seeds.rb
```ruby
# db/seeds.rb
puts "Clearing existing data..."
AlbumMemory.destroy_all
Album.destroy_all
Memory.destroy_all
Milestone.destroy_all
Admin.destroy_all

puts "Creating admin..."
Admin.create!(
  email: 'admin@nachinacon.com',
  password: 'password123',
  name: 'Admin'
)

puts "Creating albums..."
albums = [
  { name: 'Sinh nhật', description: 'Những bữa tiệc sinh nhật của bé' },
  { name: 'Đi chơi', description: 'Những chuyến đi chơi vui vẻ' },
  { name: 'Gia đình', description: 'Khoảnh khắc bên gia đình' }
]

created_albums = albums.map do |attrs|
  Album.create!(attrs)
end

puts "Creating memories..."
memories_data = [
  { title: 'Lần đầu tắm biển', caption: 'Bé rất thích nước!',
    age_group: '6-12m', memory_type: 'photo', taken_at: 8.months.ago },
  { title: 'Sinh nhật 1 tuổi', caption: 'Bữa tiệc đầu tiên',
    age_group: '1-2y', memory_type: 'photo', taken_at: 1.year.ago },
  { title: 'Tập đi', caption: 'Những bước chân đầu tiên',
    age_group: '1-2y', memory_type: 'photo', taken_at: 11.months.ago },
  { title: 'Ăn dặm lần đầu', caption: 'Bé ăn cháo rất ngon',
    age_group: '6-12m', memory_type: 'photo', taken_at: 6.months.ago },
  { title: 'Chơi với ông bà', caption: 'Bé được ông bà cưng lắm',
    age_group: '3-6m', memory_type: 'photo', taken_at: 4.months.ago },
  { title: 'Nụ cười đầu tiên', caption: 'Bé cười tươi quá!',
    age_group: '0-3m', memory_type: 'photo', taken_at: 2.months.ago },
]

memories_data.each do |attrs|
  Memory.create!(attrs)
end

# Assign some memories to albums
Memory.first(2).each { |m| m.albums << created_albums[0] }
Memory.last(2).each { |m| m.albums << created_albums[1] }

puts "Creating milestones..."
milestones = [
  { name: 'Nụ cười đầu tiên', milestone_type: 'first_smile',
    achieved_at: 2.months.ago, description: 'Bé cười khi thấy mẹ' },
  { name: 'Tiếng cười đầu tiên', milestone_type: 'first_laugh',
    achieved_at: 4.months.ago, description: 'Bé cười thành tiếng' },
  { name: 'Bò lần đầu', milestone_type: 'first_crawl',
    achieved_at: 8.months.ago, description: 'Bé bò được một đoạn' },
  { name: 'Bước đi đầu tiên', milestone_type: 'first_step',
    achieved_at: 11.months.ago, description: 'Bé đi được 3 bước' },
  { name: 'Sinh nhật 1 tuổi', milestone_type: 'first_birthday',
    achieved_at: 1.year.ago, description: 'Bữa tiệc đầu tiên' },
  { name: 'Từ đầu tiên', milestone_type: 'first_word',
    achieved_at: nil, description: 'Chờ bé nói...' },
]

milestones.each do |attrs|
  Milestone.create!(attrs)
end

puts "Seed completed!"
puts "Admin: admin@nachinacon.com / password123"
puts "Created #{Memory.count} memories"
puts "Created #{Milestone.count} milestones"
puts "Created #{Album.count} albums"
```

### 2. Run seeds
```bash
rails db:seed
```

### 3. Manual Testing Checklist

#### Public Pages
- [ ] Home page loads, shows stats
- [ ] Timeline shows memories grid
- [ ] Timeline filter by age group works
- [ ] Milestones shows vertical timeline
- [ ] Albums grid displays correctly
- [ ] Album detail shows memories
- [ ] Navigation works on mobile
- [ ] Images display correctly

#### Admin Panel
- [ ] Login works with seed credentials
- [ ] Dashboard shows correct stats
- [ ] Create new memory
- [ ] Upload image for memory
- [ ] Edit memory, assign to album
- [ ] Delete memory
- [ ] Create/edit/delete milestone
- [ ] Create/edit/delete album
- [ ] Logout works

#### Responsive
- [ ] Test on iPhone (375px)
- [ ] Test on iPad (768px)
- [ ] Test on Desktop (1280px)

## Todo List
- [ ] Update seeds.rb with full data
- [ ] Run seeds successfully
- [ ] Test public home page
- [ ] Test public timeline
- [ ] Test public milestones
- [ ] Test public albums
- [ ] Test admin login
- [ ] Test admin CRUD memories
- [ ] Test admin CRUD milestones
- [ ] Test admin CRUD albums
- [ ] Test mobile responsiveness
- [ ] Fix any bugs found

## Success Criteria
- [ ] `rails db:seed` runs without errors
- [ ] All public pages render correctly
- [ ] All admin CRUD operations work
- [ ] No console errors
- [ ] Responsive on all breakpoints

## Risk Assessment
- **Low:** Seed data is simple
- May need to re-run if schema changes

## Security Considerations
- Default password chỉ dùng cho dev
- Production cần đổi password

## Next Steps
→ Production deployment (optional future phase)
