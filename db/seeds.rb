# frozen_string_literal: true

# Only create admin user - DO NOT create sample data on production
# Sample data (albums, memories, milestones) should be created via admin panel

# Delete old admin if exists
old_admin = AdminUser.find_by(email: 'admin@nachinacon.com')
if old_admin
  old_admin.destroy
  puts "Old admin removed: admin@nachinacon.com"
end

# Create or reset default admin user
admin = AdminUser.find_or_initialize_by(email: 'admin@nachinacon.info')
admin.name = 'Admin'
# Always reset password (even if admin already exists)
admin.password = 'ngocanh0712'
admin.password_confirmation = 'ngocanh0712'

if admin.save
  puts "✓ Admin user created/updated: admin@nachinacon.info"
else
  puts "✗ Failed to save admin user: #{admin.errors.full_messages.join(', ')}"
  # Force delete and recreate if save fails
  admin.delete if admin.persisted?
  admin = AdminUser.create!(
    email: 'admin@nachinacon.info',
    name: 'Admin',
    password: 'ngocanh0712',
    password_confirmation: 'ngocanh0712'
  )
  puts "✓ Admin user recreated: admin@nachinacon.info"
end

puts "\n✅ Admin user setup completed!"

# Create default site settings
puts "\n⚙️  Setting up site settings..."
SiteSetting::DEFAULTS.each do |key, value|
  setting = SiteSetting.find_or_initialize_by(key: key)
  next if setting.persisted? # Don't overwrite existing settings

  setting.value = value
  setting.value_type = (key.include?('date') ? 'date' : 'string')
  setting.save!
  puts "  ✓ #{key}: #{value}"
end
puts "✅ Site settings configured!"

# Create default tags
puts "\n🏷️  Creating default tags..."
default_tags = [
  { name: 'Sinh nhật', color: '#F2C2C2' },
  { name: 'Gia đình', color: '#C1DDD8' },
  { name: 'Du lịch', color: '#C0DFD0' },
  { name: 'Học tập', color: '#C9E4F5' },
  { name: 'Vui chơi', color: '#F5D5C0' },
  { name: 'Ăn uống', color: '#E8B0B0' },
  { name: 'Mốc quan trọng', color: '#E8D4F0' }
]

default_tags.each do |tag_data|
  tag = Tag.find_or_create_by!(name: tag_data[:name]) do |t|
    t.color = tag_data[:color]
  end
  puts "  ✓ #{tag.name}"
end
puts "✅ Tags created!"

exit # Stop here - memories already created, prevent duplicates

# Now create memories with real photos
puts "\n🌱 Starting to seed memories for Gia Minh (Nacon)...\n\n"

# Clear old data
puts "Clearing old data..."
AlbumMemory.destroy_all
Memory.destroy_all
Album.destroy_all
Milestone.where(milestone_type: 'custom').destroy_all

# Create predefined milestones
puts "\n📍 Creating milestones..."
Milestone::MILESTONE_TYPES.each do |type, data|
  next if type == 'custom'

  Milestone.find_or_create_by!(milestone_type: type) do |milestone|
    milestone.name = data[:name]
    milestone.icon = data[:icon]
    milestone.description = "Mốc quan trọng: #{data[:name]}"
    puts "  ✓ #{data[:name]}"
  end
end

# Mark some milestones as achieved with meaningful dates and images
achieved_milestones_data = [
  { type: 'first_smile', months_ago: 10, image: 'z7358505070138_cdc7805f8de23d67402e4ad507b449d0.jpg' },
  { type: 'first_laugh', months_ago: 9, image: 'z7358505059924_12d63f42daabb58995a7acded47025e8.jpg' },
  { type: 'first_tooth', months_ago: 8, image: 'z7358504726520_5b668e90ccaebb970cad911da4d4c270.jpg' },
  { type: 'first_food', months_ago: 7, image: 'z7358504726637_38efce5a353372f11f6659c0d7c6a9a5.jpg' },
  { type: 'first_crawl', months_ago: 6, image: 'z7358504725146_6c36054999325938964675a5dc01a9f8.jpg' },
  { type: 'first_step', months_ago: 3, image: 'z7358504726994_ac8bc5e50ee169d7617f42095a4a7d47.jpg' },
  { type: 'first_birthday', months_ago: 2, image: 'z7358504731981_f01495c3aa99aaf64cda7ffe5e442a89.jpg' }
]

achieved_milestones_data.each do |data|
  milestone = Milestone.find_by(milestone_type: data[:type])
  next unless milestone

  # Set achieved date and image path
  milestone.update!(
    achieved_at: data[:months_ago].months.ago,
    image_path: "/images/nachinacon/#{data[:image]}"
  )
  puts "  ✓ Marked: #{milestone.name} (with image)"
end

# Create albums
puts "\n📚 Creating albums..."
albums_data = [
  {
    name: 'Những ngày đầu đời',
    description: 'Khoảnh khắc chào đời và những tuần đầu tiên của Gia Minh. Từng giây phút đều quý giá và đáng nhớ.',
    cover_description: 'Nacon khi mới sinh',
    cover_image: 'z7358504728666_f87632e9196275aa437c0639d151e304.jpg'
  },
  {
    name: 'Sinh nhật 1 tuổi',
    description: 'Tiệc sinh nhật đầu tiên của Nacon - một cột mốc đặc biệt với gia đình và bạn bè.',
    cover_description: 'Tiệc sinh nhật rực rỡ',
    cover_image: 'z7358504731981_f01495c3aa99aaf64cda7ffe5e442a89.jpg'
  },
  {
    name: 'Ngày lễ đặc biệt',
    description: 'Những dịp lễ Tết, Noel đầu tiên cùng con yêu. Mỗi ngày lễ đều là kỷ niệm.',
    cover_description: 'Các ngày lễ đầu đời',
    cover_image: 'z7358504733153_bd48f2f02de3036f26aa50f1f4c8bf51.jpg'
  },
  {
    name: 'Nacon học bơi',
    description: 'Những buổi học bơi đầu tiên. Con rất thích chơi với nước!',
    cover_description: 'Bơi lội cùng con',
    cover_image: 'z7358504725146_6c36054999325938964675a5dc01a9f8.jpg'
  },
  {
    name: 'Khoảnh khắc gia đình',
    description: 'Những khoảnh khắc ấm áp bên gia đình - ông bà, bố mẹ cùng Nacon.',
    cover_description: 'Gia đình hạnh phúc',
    cover_image: 'z7358513032589_f2afd6aa94473227b60ff7284dddb601.jpg'
  },
  {
    name: 'Mỗi ngày lớn khôn',
    description: 'Những khoảnh khắc bình thường nhưng đầy ý nghĩa. Mỗi ngày con đều lớn lên một chút.',
    cover_description: 'Hành trình lớn khôn',
    cover_image: 'z7358505065706_f2d8773a7188812ea5e31989b042fabc.jpg'
  }
]

albums = {}
albums_data.each do |album_data|
  album = Album.create!(
    name: album_data[:name],
    description: album_data[:description],
    cover_image_path: "/images/nachinacon/#{album_data[:cover_image]}"
  )
  albums[album_data[:name]] = album
  puts "  ✓ #{album_data[:name]} (with cover image)"
end

# Helper method to set image path (using public folder for production persistence)
def set_image_path_for_memory(memory, image_filename)
  # Check if image exists in public folder
  public_path = Rails.root.join('public', 'images', 'nachinacon', image_filename)
  if File.exist?(public_path)
    memory.image_path = "/images/nachinacon/#{image_filename}"
    true
  else
    puts "    ⚠️  Image not found: #{image_filename}"
    false
  end
end

# Create memories with real photos
puts "\n💝 Creating memories with photos..."

memories_data = [
  # Những ngày đầu đời (0-3 tháng)
  {
    title: 'Chào đời',
    caption: 'Ngày con chào đời, cuộc sống của bố mẹ thay đổi hoàn toàn. Một thiên thần nhỏ đã đến với gia đình. Gia Minh, con là niềm hạnh phúc lớn nhất của bố mẹ.',
    age_group: '0-3m',
    memory_type: 'photo',
    taken_at: 12.months.ago,
    image: 'z7358504728666_f87632e9196275aa437c0639d151e304.jpg',
    albums: ['Những ngày đầu đời']
  },
  {
    title: 'Nụ cười đầu tiên',
    caption: 'Lần đầu tiên Nacon cười tươi như thế này, bố mẹ vui lắm! Nụ cười của con là điều tuyệt vời nhất trên đời. Cười lên đi con, để bố mẹ thấy con hạnh phúc.',
    age_group: '0-3m',
    memory_type: 'photo',
    taken_at: 10.months.ago,
    image: 'z7358505070138_cdc7805f8de23d67402e4ad507b449d0.jpg',
    albums: ['Những ngày đầu đời', 'Mỗi ngày lớn khôn']
  },
  {
    title: 'Tết đầu tiên',
    caption: 'Tết đầu tiên của Nacon! Con còn nhỏ xíu nhưng đã được mặc đồ đẹp đi chúc Tết ông bà. Năm nay nhà mình có thêm thành viên mới, Tết vui hơn nhiều.',
    age_group: '0-3m',
    memory_type: 'photo',
    taken_at: 11.months.ago,
    image: 'z7358505072874_31bbd992f898535d26f7e930c1dbb8de.jpg',
    albums: ['Ngày lễ đặc biệt', 'Những ngày đầu đời']
  },
  {
    title: 'Ảnh gia đình ấm áp',
    caption: 'Cả gia đình cùng chụp ảnh với Nacon. Ông bà, bố mẹ đều rất yêu thương con. Con là niềm vui, niềm tự hào của cả nhà.',
    age_group: '0-3m',
    memory_type: 'photo',
    taken_at: 10.months.ago,
    image: 'z7358513032589_f2afd6aa94473227b60ff7284dddb601.jpg',
    albums: ['Khoảnh khắc gia đình', 'Những ngày đầu đời']
  },

  # 6-12 tháng
  {
    title: 'Học bơi lần đầu',
    caption: 'Lần đầu tiên Nacon xuống bể bơi với phao hình ong vàng. Tuy hơi ngại ngại nhưng con rất dũng cảm! Bơi giỏi lắm con ơi.',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 8.months.ago,
    image: 'z7358504725146_6c36054999325938964675a5dc01a9f8.jpg',
    albums: ['Nacon học bơi', 'Mỗi ngày lớn khôn']
  },
  {
    title: 'Chơi camping',
    caption: 'Concept chụp ảnh camping nhà của Nacon. Con ngồi ghế gỗ đội mũ rộng vành trông như một nhà thám hiểm nhỏ. Cute quá đi!',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 7.months.ago,
    image: 'z7358505065706_f2d8773a7188812ea5e31989b042fabc.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },
  {
    title: 'Nacon tươi cười',
    caption: 'Nụ cười tươi rói của Nacon khi cầm thẻ chơi. Con cười là bố mẹ vui rồi! Những khoảnh khắc bình dị nhưng đầy ý nghĩa như thế này.',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 8.months.ago,
    image: 'z7358505059924_12d63f42daabb58995a7acded47025e8.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },

  # 1-2 tuổi
  {
    title: 'Sinh nhật 1 tuổi',
    caption: 'Sinh nhật 1 tuổi của Gia Minh - Nacon! Tiệc sinh nhật với theme màu cam vàng tươi sáng, có backdrop tên con, bóng bay và bánh kem. Cả nhà rất vui, con đã lớn thêm 1 tuổi rồi!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 2.months.ago,
    image: 'z7358504731981_f01495c3aa99aaf64cda7ffe5e442a89.jpg',
    albums: ['Sinh nhật 1 tuổi', 'Mỗi ngày lớn khôn']
  },
  {
    title: 'Noel đầu tiên',
    caption: 'Noel đầu tiên của Nacon! Con mặc đồ ông già Noel đỏ chói, ngồi trong lều có chữ "사랑해" (Yêu con). Bên cạnh có người tuyết và quà Noel. Noel vui vẻ nha con!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 1.month.ago,
    image: 'z7358504733153_bd48f2f02de3036f26aa50f1f4c8bf51.jpg',
    albums: ['Ngày lễ đặc biệt', 'Mỗi ngày lớn khôn']
  },
  {
    title: 'Chơi với gấu bông',
    caption: 'Nacon chơi với gấu bông trên giường, cười toe toét. Con thích chơi với đồ chơi mềm mại, đặc biệt là những con thú nhồi. Khoảnh khắc bình yên của con.',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 3.months.ago,
    image: 'z7358504721314_bd19081c4f1a8f94d811cf61ae95df48.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },

  # Thêm kỷ niệm mới
  {
    title: 'Nacon ăn cơm ngoan',
    caption: 'Con ăn cơm rất ngoan và tự lập. Nacon cầm thìa tự ăn, tuy hơi bẩn nhưng con rất vui. Bố mẹ tự hào lắm con ơi!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 4.months.ago,
    image: 'z7358504722217_75c45c977c00c5cb3c31393427ab3400.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },
  {
    title: 'Học đi xe',
    caption: 'Lần đầu tiên Nacon ngồi trên xe đẩy, con rất thích! Mắt con sáng lên khi được đi dạo quanh nhà.',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 9.months.ago,
    image: 'z7358504722640_e94ff2f20cffee5ed62df8c834e3321f.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },
  {
    title: 'Chụp ảnh cùng bố',
    caption: 'Khoảnh khắc ấm áp của bố và con. Nacon nằm trong vòng tay bố, an toàn và hạnh phúc. Bố luôn yêu con nhất!',
    age_group: '0-3m',
    memory_type: 'photo',
    taken_at: 11.months.ago,
    image: 'z7358504728174_95860b76f4f99e19ed41587445e4d035.jpg',
    albums: ['Khoảnh khắc gia đình']
  },
  {
    title: 'Ngủ ngon lành',
    caption: 'Con ngủ say trong giấc ngủ trưa. Khuôn mặt bình yên của con là điều đẹp nhất đời bố mẹ. Ngủ ngon nha con yêu!',
    age_group: '0-3m',
    memory_type: 'photo',
    taken_at: 10.months.ago,
    image: 'z7358504729198_6c601f6f091d3a5d02f58c11249da8c7.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },
  {
    title: 'Vui chơi với đồ chơi',
    caption: 'Nacon chơi với đồ chơi nhiều màu sắc. Con rất thích khám phá những món đồ chơi mới. Sự tò mò của con thật đáng yêu!',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 8.months.ago,
    image: 'z7358504730813_c5fc79b553f86901a02a988fa329dddc.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },
  {
    title: 'Tập ngồi',
    caption: 'Con đã tập ngồi được rồi! Tuy còn hơi loạng choạng nhưng con rất cố gắng. Bố mẹ rất tự hào về sự tiến bộ của con.',
    age_group: '6-12m',
    memory_type: 'photo',
    taken_at: 7.months.ago,
    image: 'z7358505061164_11294b964182ee7894d5d251ac163446.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },
  {
    title: 'Chụp ảnh đẹp',
    caption: 'Nacon chụp ảnh trong bộ đồ đẹp. Con nhìn thật xinh xắn và đáng yêu. Mỗi khoảnh khắc của con đều quý giá!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 2.months.ago,
    image: 'z7358505062125_665de73ac7a04f8eacce14c3c7062e96.jpg',
    albums: ['Mỗi ngày lớn khôn']
  },
  {
    title: 'Cười tươi rói',
    caption: 'Nụ cười tươi như hoa của Nacon. Con cười là bố mẹ quên hết mệt mỏi. Yêu con nhiều lắm!',
    age_group: '1-2y',
    memory_type: 'photo',
    taken_at: 3.months.ago,
    image: 'z7358505069389_cf8c2316ff4789c17f254f379f1ca41d.jpg',
    albums: ['Mỗi ngày lớn khôn']
  }
]

memories_data.each_with_index do |data, index|
  memory = Memory.create!(
    title: data[:title],
    caption: data[:caption],
    age_group: data[:age_group],
    memory_type: data[:memory_type],
    taken_at: data[:taken_at]
  )

  # Set image path
  if data[:image] && set_image_path_for_memory(memory, data[:image])
    memory.save!
    puts "  ✓ [#{index + 1}/#{memories_data.length}] #{data[:title]} (with photo: #{data[:image]})"
  else
    puts "  ✓ [#{index + 1}/#{memories_data.length}] #{data[:title]} (no photo)"
  end

  # Add to albums
  data[:albums]&.each do |album_name|
    album = albums[album_name]
    if album
      AlbumMemory.create!(album: album, memory: memory)
    end
  end
end

puts "\n✅ Seeds completed successfully!"
puts "\n📊 Summary:"
puts "  - Albums: #{Album.count}"
puts "  - Memories: #{Memory.count}"
puts "  - Milestones: #{Milestone.count}"
puts "  - Achieved milestones: #{Milestone.where.not(achieved_at: nil).count}"
puts "\n💙 Nacon's memories are ready to be viewed!\n\n"
