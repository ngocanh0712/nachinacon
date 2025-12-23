# frozen_string_literal: true

# Create default admin user
admin = AdminUser.find_or_initialize_by(email: 'admin@nachinacon.info')
admin.name = 'Admin'
admin.password = 'ngocanh0712'
admin.save!
puts "Admin user: admin@nachinacon.info"

# Delete old admin if exists
old_admin = AdminUser.find_by(email: 'admin@nachinacon.com')
old_admin&.destroy
puts "Old admin removed" if old_admin

# Create predefined milestones
Milestone::MILESTONE_TYPES.each do |type, data|
  next if type == 'custom'

  Milestone.find_or_create_by!(milestone_type: type) do |milestone|
    milestone.name = data[:name]
    milestone.icon = data[:icon]
    milestone.description = "Moc quan trong: #{data[:name]}"
    puts "Created milestone: #{data[:name]}"
  end
end

# Create sample albums
albums_data = [
  { name: 'Thang dau doi', description: 'Nhung khoanh khac dau tien cua con' },
  { name: 'Sinh nhat 1 tuoi', description: 'Tiec sinh nhat dau tien cua be' },
  { name: 'Ngay thuong', description: 'Nhung khoanh khac binh di hang ngay' },
  { name: 'Di choi', description: 'Nhung chuyen du lich va di choi cung gia dinh' }
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
    title: 'Nu cuoi dau tien',
    caption: 'Be cuoi lan dau tien khi nhin thay bo me. Khoanh khac dac biet qua!',
    age_group: '0-3m',
    memory_type: 'photo',
    taken_at: 2.months.ago
  },
  {
    title: 'Lat nguoi',
    caption: 'Be da tu lat nguoi duoc roi! Mot cot moc lon trong su phat trien.',
    age_group: '3-6m',
    memory_type: 'photo',
    taken_at: 4.months.ago
  },
  {
    title: 'Bua an dam dau tien',
    caption: 'Lan dau tien be an dam. Rat thich rau va trai cay!',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 6.months.ago
  },
  {
    title: 'Tap bo',
    caption: 'Be dang tap nhung buoc di dau tien. Moi ngay mot tien bo!',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 11.months.ago
  },
  {
    title: 'Sinh nhat 1 tuoi',
    caption: 'Bua tiec sinh nhat dau tien. Be rat vui khi thoi nen!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 1.year.ago
  },
  {
    title: 'Noi tieng dau tien',
    caption: 'Be noi "mama" va "baba" rat ro rang roi!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 14.months.ago
  },
  {
    title: 'Di cong vien',
    caption: 'Buoi chieu di choi cong vien gan nha. Be thich xich du lam!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 16.months.ago
  },
  {
    title: 'Hoc ve',
    caption: 'Be bat dau thich ve. Toan ve nhung duong ngoang nghoeo dang yeu.',
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
first_album = Album.find_by(name: 'Thang dau doi')
birthday_album = Album.find_by(name: 'Sinh nhat 1 tuoi')
daily_album = Album.find_by(name: 'Ngay thuong')
travel_album = Album.find_by(name: 'Di choi')

if first_album
  Memory.where(age_group: %w[0-3m 3-6m]).each do |memory|
    AlbumMemory.find_or_create_by!(album: first_album, memory: memory)
    puts "Added #{memory.title} to #{first_album.name}"
  end
end

if birthday_album
  Memory.find_by(title: 'Sinh nhat 1 tuoi')&.tap do |memory|
    AlbumMemory.find_or_create_by!(album: birthday_album, memory: memory)
    puts "Added #{memory.title} to #{birthday_album.name}"
  end
end

if daily_album
  Memory.where(title: ['Hoc ve', 'Noi tieng dau tien']).each do |memory|
    AlbumMemory.find_or_create_by!(album: daily_album, memory: memory)
    puts "Added #{memory.title} to #{daily_album.name}"
  end
end

if travel_album
  Memory.find_by(title: 'Di cong vien')&.tap do |memory|
    AlbumMemory.find_or_create_by!(album: travel_album, memory: memory)
    puts "Added #{memory.title} to #{travel_album.name}"
  end
end

puts 'Seeds completed!'
