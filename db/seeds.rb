# frozen_string_literal: true

# Delete old admin if exists
old_admin = AdminUser.find_by(email: 'admin@nachinacon.com')
if old_admin
  old_admin.destroy
  puts "Old admin removed: admin@nachinacon.com"
end

# Create default admin user
admin = AdminUser.find_or_initialize_by(email: 'admin@nachinacon.info')
admin.name = 'Admin'
admin.password = 'ngocanh0712'
admin.password_confirmation = 'ngocanh0712'
admin.save!
puts "Admin user created/updated: admin@nachinacon.info"

# Create predefined milestones
Milestone::MILESTONE_TYPES.each do |type, data|
  next if type == 'custom'

  Milestone.find_or_create_by!(milestone_type: type) do |milestone|
    milestone.name = data[:name]
    milestone.icon = data[:icon]
    milestone.description = "Mốc quan trọng: #{data[:name]}"
    puts "Created milestone: #{data[:name]}"
  end
end

# Create sample albums
albums_data = [
  { name: 'Tháng đầu đời', description: 'Những khoảnh khắc đầu tiên của con' },
  { name: 'Sinh nhật 1 tuổi', description: 'Tiệc sinh nhật đầu tiên của bé' },
  { name: 'Ngày thường', description: 'Những khoảnh khắc bình dị hàng ngày' },
  { name: 'Đi chơi', description: 'Những chuyến du lịch và đi chơi cùng gia đình' }
]

albums_data.each do |album_data|
  Album.find_or_create_by!(name: album_data[:name]) do |album|
    album.description = album_data[:description]
    puts "Created album: #{album_data[:name]}"
  end
end

# Create sample memories (without images - you can add images later via admin panel)
# Valid age_groups: '0-3m', '3-6m', '6-12m', '1-2y', '2-3y'
memories_data = [
  {
    title: 'Nụ cười đầu tiên',
    caption: 'Bé cười lần đầu tiên khi nhìn thấy bố mẹ. Khoảnh khắc đặc biệt quá!',
    age_group: '0-3m',
    memory_type: 'photo',
    taken_at: 2.months.ago
  },
  {
    title: 'Lật người',
    caption: 'Bé đã tự lật người được rồi! Một cột mốc lớn trong sự phát triển.',
    age_group: '3-6m',
    memory_type: 'photo',
    taken_at: 4.months.ago
  },
  {
    title: 'Bữa ăn dặm đầu tiên',
    caption: 'Lần đầu tiên bé ăn dặm. Rất thích rau và trái cây!',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 6.months.ago
  },
  {
    title: 'Tập bò',
    caption: 'Bé đang tập những bước đi đầu tiên. Mỗi ngày một tiến bộ!',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 11.months.ago
  },
  {
    title: 'Sinh nhật 1 tuổi',
    caption: 'Bữa tiệc sinh nhật đầu tiên. Bé rất vui khi thổi nến!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 1.year.ago
  },
  {
    title: 'Nói tiếng đầu tiên',
    caption: 'Bé nói "mama" và "baba" rất rõ ràng rồi!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 14.months.ago
  },
  {
    title: 'Đi công viên',
    caption: 'Buổi chiều đi chơi công viên gần nhà. Bé thích xích đu lắm!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 16.months.ago
  },
  {
    title: 'Học vẽ',
    caption: 'Bé bắt đầu thích vẽ. Toàn vẽ những đường ngoằng nghèo đáng yêu.',
    age_group: '2-3y',
    memory_type: 'photo',
    taken_at: 2.years.ago
  }
]

memories_data.each do |memory_data|
  Memory.find_or_create_by!(title: memory_data[:title]) do |memory|
    memory.caption = memory_data[:caption]
    memory.age_group = memory_data[:age_group]
    memory.memory_type = memory_data[:memory_type]
    memory.taken_at = memory_data[:taken_at]
    puts "Created memory: #{memory_data[:title]}"
  end
end

# Mark some milestones as achieved
# Valid milestone types: first_smile, first_laugh, first_tooth, first_word, first_crawl, first_step, first_food, first_birthday, second_birthday, third_birthday
achieved_milestones = ['first_smile', 'first_laugh', 'first_tooth', 'first_crawl', 'first_step', 'first_food', 'first_birthday']
achieved_milestones.each_with_index do |type, index|
  milestone = Milestone.find_by(milestone_type: type)
  next unless milestone

  milestone.update!(achieved_at: (12 - index).months.ago)
  puts "Marked as achieved: #{milestone.name}"
end

# Associate some memories with albums
first_album = Album.find_by(name: 'Tháng đầu đời')
birthday_album = Album.find_by(name: 'Sinh nhật 1 tuổi')
daily_album = Album.find_by(name: 'Ngày thường')
travel_album = Album.find_by(name: 'Đi chơi')

if first_album
  Memory.where(age_group: %w[0-3m 3-6m]).each do |memory|
    AlbumMemory.find_or_create_by!(album: first_album, memory: memory)
    puts "Added #{memory.title} to #{first_album.name}"
  end
end

if birthday_album
  Memory.find_by(title: 'Sinh nhật 1 tuổi')&.tap do |memory|
    AlbumMemory.find_or_create_by!(album: birthday_album, memory: memory)
    puts "Added #{memory.title} to #{birthday_album.name}"
  end
end

if daily_album
  Memory.where(title: ['Học vẽ', 'Nói tiếng đầu tiên']).each do |memory|
    AlbumMemory.find_or_create_by!(album: daily_album, memory: memory)
    puts "Added #{memory.title} to #{daily_album.name}"
  end
end

if travel_album
  Memory.find_by(title: 'Đi công viên')&.tap do |memory|
    AlbumMemory.find_or_create_by!(album: travel_album, memory: memory)
    puts "Added #{memory.title} to #{travel_album.name}"
  end
end

puts 'Seeds completed!'
