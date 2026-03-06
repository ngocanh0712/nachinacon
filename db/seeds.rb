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

# Seed bài viết chăm sóc sức khoẻ mẹ & bé (nguồn tham khảo uy tín)
puts "\n🏥 Tạo bài viết sức khoẻ mẹ & bé..."
health_tips_data = [
  {
    title: 'Mẹ sau sinh nên ăn gì để nhiều sữa và nhanh hồi phục?',
    content: "Theo Viện Dinh dưỡng Quốc gia, mẹ sau sinh cần tăng 500 kcal/ngày so với bình thường để đảm bảo đủ dinh dưỡng cho cả mẹ và bé qua sữa mẹ.\n\n**Thực phẩm giúp lợi sữa:**\n- Cháo móng giò hầm đu đủ xanh: nguồn collagen và vitamin giúp lợi sữa tự nhiên\n- Cá hồi, cá thu: giàu omega-3 DHA, hỗ trợ phát triển não bé qua sữa mẹ\n- Rau ngót canh: theo Đông y, rau ngót có tính mát, giúp thanh nhiệt và lợi sữa\n- Yến mạch: chứa saponin kích thích hormone prolactin tạo sữa\n- Hạt vừng đen: giàu canxi (975mg/100g), gấp 10 lần sữa bò\n\n**Nhóm thực phẩm thiết yếu mỗi ngày:**\n- Protein: 2-3 phần (thịt, cá, trứng, đậu phụ)\n- Rau xanh: 400-500g (đặc biệt rau lá xanh đậm giàu sắt)\n- Trái cây: 2-3 phần (đu đủ chín, chuối, cam)\n- Sữa/sữa chua: 500ml bổ sung canxi\n- Nước: 2.5-3 lít/ngày (nước ấm, nước canh, sữa)\n\n**Thực phẩm mẹ nên hạn chế:**\n- Caffeine: không quá 200mg/ngày (khoảng 1 ly cà phê)\n- Đồ cay nóng: có thể gây đầy hơi cho bé qua sữa\n- Rượu bia: ảnh hưởng trực tiếp đến chất lượng sữa\n- Thực phẩm gây dị ứng: sữa bò, đậu phộng (nếu gia đình có tiền sử dị ứng)\n\n**Lưu ý quan trọng:** Mỗi cơ thể mẹ khác nhau. Nếu bé bú xong hay quấy khóc, đầy hơi, mẹ nên xem lại chế độ ăn. Tham khảo bác sĩ dinh dưỡng nếu cần.",
    category: 'nutrition_mom',
    source_url: 'https://vinmec.com/vie/bai-viet/me-sau-sinh-nen-an-gi-de-nhieu-sua-vi',
    image_url: 'https://images.unsplash.com/photo-1493894473891-10fc1e5dbd22?w=800&q=80',
    position: 1
  },
  {
    title: 'Chăm sóc trẻ sơ sinh 0-3 tháng: Kim chỉ nam cho bố mẹ mới',
    content: "Theo Bệnh viện Nhi Trung ương, 3 tháng đầu đời là \"tam cá nguyệt thứ tư\" - bé vẫn đang thích nghi với thế giới bên ngoài. Đây là giai đoạn cần sự chăm sóc đặc biệt nhất.\n\n**1. Nuôi con bằng sữa mẹ:**\n- Cho bú sớm trong 1 giờ đầu sau sinh (\"giờ vàng\")\n- Bú mẹ hoàn toàn trong 6 tháng đầu (WHO khuyến nghị)\n- Tần suất: 8-12 lần/ngày, mỗi lần 15-20 phút mỗi bên\n- Dấu hiệu bé bú đủ: tăng cân đều, 6-8 tã ướt/ngày\n\n**2. Giấc ngủ an toàn:**\n- Bé sơ sinh ngủ 16-17 tiếng/ngày, chia thành nhiều giấc\n- Luôn đặt bé NẰM NGỬA khi ngủ (giảm nguy cơ SIDS)\n- Nệm phẳng, cứng. Không dùng gối, chăn mềm, đồ chơi trong nôi\n- Nhiệt độ phòng 24-26°C, mặc đồ vừa phải\n\n**3. Chăm sóc rốn:**\n- Giữ rốn khô và sạch (không cần bôi cồn)\n- Gấp mép tã xuống dưới rốn để thoáng khí\n- Rốn thường rụng sau 7-14 ngày\n- Đi khám nếu: rốn chảy mủ, có mùi hôi, đỏ sưng quanh rốn\n\n**4. Tắm cho bé:**\n- Nhiệt độ nước: 37-38°C (kiểm tra bằng khuỷu tay)\n- Tắm nhanh 5-10 phút, tránh gió lùa\n- Sử dụng sữa tắm dịu nhẹ, pH 5.5 cho trẻ sơ sinh\n\n**5. Dấu hiệu nguy hiểm cần đi cấp cứu:**\n- Sốt ≥ 38°C ở trẻ dưới 3 tháng\n- Bỏ bú, bú kém\n- Thở nhanh > 60 lần/phút, rút lõm ngực\n- Vàng da lan đến tay chân\n- Co giật",
    category: 'newborn_care',
    source_url: 'https://www.vinmec.com/vie/bai-viet/cham-soc-tre-so-sinh-0-3-thang-tuoi-vi',
    image_url: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=800&q=80',
    position: 2
  },
  {
    title: 'Lịch tiêm chủng đầy đủ cho bé từ 0-24 tháng (Cập nhật 2025)',
    content: "Theo Chương trình Tiêm chủng Mở rộng Quốc gia và khuyến cáo từ Hội Nhi khoa Việt Nam, đây là lịch tiêm chủng chuẩn cho bé.\n\n**NGAY SAU SINH (trong 24 giờ đầu):**\n- Viêm gan B liều sơ sinh\n- BCG (phòng lao)\n\n**2 THÁNG TUỔI:**\n- Vắc-xin 6 trong 1 Infanrix Hexa (mũi 1): bạch hầu, ho gà, uốn ván, bại liệt, Hib, viêm gan B\n- Phế cầu Synflorix/Prevenar 13 (mũi 1)\n- Rotavirus (liều 1)\n\n**4 THÁNG TUỔI:**\n- 6 trong 1 (mũi 2)\n- Phế cầu (mũi 2)\n- Rotavirus (liều 2)\n\n**6 THÁNG TUỔI:**\n- 6 trong 1 (mũi 3)\n- Cúm mùa (mũi 1 - cách mũi 2 tối thiểu 4 tuần)\n\n**9 THÁNG:**\n- Sởi đơn (mũi 1) - theo chương trình TCMR\n\n**12 THÁNG:**\n- MMR - Sởi, Quai bị, Rubella (mũi 1)\n- Thuỷ đậu (mũi 1)\n- Viêm não Nhật Bản (mũi 1, mũi 2 cách 1-2 tuần)\n- Viêm gan A (mũi 1)\n\n**15-18 THÁNG:**\n- 6 trong 1 hoặc 5 trong 1 (mũi nhắc lại)\n- Phế cầu (mũi nhắc)\n\n**Lưu ý sau tiêm:**\n- Ở lại cơ sở y tế 30 phút theo dõi\n- Bé có thể sốt nhẹ 1-2 ngày, sưng đau tại chỗ tiêm\n- Chườm mát (không chườm nóng) tại vị trí tiêm\n- Dùng Paracetamol nếu bé sốt ≥ 38.5°C\n- Đưa bé đi khám ngay nếu: sốt cao > 39°C kéo dài, khóc thét > 3 giờ, co giật, phát ban toàn thân",
    category: 'vaccination',
    source_url: 'https://vnvc.vn/lich-tiem-chung-cho-tre',
    image_url: 'https://images.unsplash.com/photo-1632053002928-1919605ee6f7?w=800&q=80',
    position: 3
  },
  {
    title: 'Trầm cảm sau sinh: Nhận biết sớm và cách vượt qua',
    content: "Theo Tổ chức Y tế Thế giới (WHO), khoảng 10-15% phụ nữ sau sinh mắc trầm cảm. Tại Việt Nam, con số này có thể lên đến 20% do áp lực văn hoá và thiếu hỗ trợ. Đây KHÔNG phải lỗi của mẹ.\n\n**Phân biệt Baby Blues và Trầm cảm sau sinh:**\n\nBaby Blues (bình thường):\n- Xuất hiện 2-3 ngày sau sinh, kéo dài 1-2 tuần\n- Hay khóc, cáu gắt, lo lắng nhẹ\n- Tự hết, không cần điều trị\n\nTrầm cảm sau sinh (cần can thiệp):\n- Kéo dài > 2 tuần, ngày càng nặng hơn\n- Buồn bã sâu sắc, mất hứng thú với mọi thứ\n- Không muốn chăm con, cảm giác mình là mẹ tồi\n- Mất ngủ dù rất mệt, hoặc ngủ quá nhiều\n- Thay đổi cân nặng bất thường\n- Có suy nghĩ tự gây hại bản thân hoặc con\n\n**Mẹ có thể làm gì:**\n- Chia sẻ cảm xúc với chồng, người thân tin tưởng\n- Dành 30 phút mỗi ngày cho bản thân (tắm, đọc sách, nghe nhạc)\n- Ngủ khi bé ngủ, chấp nhận việc nhà không hoàn hảo\n- Đi bộ ngoài trời 15-20 phút mỗi ngày\n- Tham gia nhóm hỗ trợ mẹ sau sinh\n\n**Bố có thể làm gì:**\n- Chia sẻ việc chăm bé (cho bú bình, thay tã, dỗ bé ngủ)\n- Lắng nghe mẹ mà KHÔNG phán xét\n- Giúp việc nhà hoặc thuê giúp việc nếu có thể\n- Động viên mẹ đi khám nếu triệu chứng kéo dài\n\n**KHI NÀO CẦN GẶP BÁC SĨ:**\n- Triệu chứng kéo dài > 2 tuần\n- Có suy nghĩ tự gây hại\n- Không thể chăm sóc bản thân hoặc con\n- Gọi đường dây nóng tâm lý: 1800 599 920 (miễn phí)",
    category: 'postpartum',
    source_url: 'https://www.who.int/news-room/fact-sheets/detail/depression',
    image_url: 'https://images.unsplash.com/photo-1531983412531-1f49a365ffed?w=800&q=80',
    position: 4
  },
  {
    title: 'Ăn dặm cho bé: Bắt đầu từ đâu, ăn gì, tránh gì?',
    content: "Theo khuyến cáo của WHO và Viện Dinh dưỡng Quốc gia Việt Nam, bé nên bắt đầu ăn dặm từ đủ 6 tháng tuổi (180 ngày). Không nên ăn dặm sớm trước 4 tháng.\n\n**Dấu hiệu bé sẵn sàng ăn dặm:**\n- Ngồi vững khi được hỗ trợ\n- Kiểm soát đầu cổ tốt\n- Quan tâm đến thức ăn của người lớn, với tay lấy\n- Mất phản xạ đẩy lưỡi (không đẩy thìa ra ngoài)\n\n**Các phương pháp ăn dặm phổ biến:**\n\n1. Ăn dặm truyền thống (Việt Nam):\n- Bắt đầu bằng bột/cháo loãng xay nhuyễn\n- Tăng dần độ thô theo tháng tuổi\n- Phù hợp văn hoá, dễ kiểm soát dinh dưỡng\n\n2. BLW (Baby Led Weaning):\n- Cho bé tự cầm nắm thức ăn dạng que/miếng mềm\n- Phát triển kỹ năng nhai, cầm nắm sớm\n- Cần giám sát chặt để tránh hóc\n\n3. Phương pháp kết hợp (phổ biến nhất):\n- Kết hợp đút thìa + cho bé tự cầm nắm\n- Linh hoạt theo từng bữa và từng giai đoạn\n\n**Thực đơn gợi ý tháng đầu ăn dặm:**\n- Tuần 1-2: Bột gạo + 1 loại rau (bí đỏ, khoai lang, cà rốt)\n- Tuần 3: Thêm thịt gà/thịt lợn nạc xay nhuyễn\n- Tuần 4: Thêm trái cây (chuối, bơ, xoài chín)\n\n**Thực phẩm TUYỆT ĐỐI tránh trước 1 tuổi:**\n- Mật ong (nguy cơ ngộ độc botulinum)\n- Sữa bò tươi thay sữa mẹ/công thức\n- Muối, đường, nước mắm\n- Các loại hạt nguyên (nguy cơ hóc)\n\n**Nguyên tắc vàng:**\n- Cho ăn 1 loại mới, đợi 3 ngày quan sát dị ứng\n- Không ép bé ăn, tôn trọng tín hiệu no\n- Ăn dặm là BỔ SUNG, sữa mẹ vẫn là chính đến 12 tháng",
    category: 'nutrition_baby',
    source_url: 'https://vinmec.com/vie/bai-viet/an-dam-cho-be-6-thang-tuoi-vi',
    image_url: 'https://images.unsplash.com/photo-1565538810643-b5bdb714032a?w=800&q=80',
    position: 5
  },
  {
    title: 'Bé bị sốt, ho, sổ mũi: Khi nào cần đi bác sĩ?',
    content: "Sốt, ho, sổ mũi là những triệu chứng thường gặp nhất ở trẻ nhỏ. Theo Bệnh viện Nhi đồng 1, trẻ dưới 2 tuổi có thể mắc 6-8 đợt cảm/năm là bình thường.\n\n**XỬ LÝ KHI BÉ BỊ SỐT:**\n\nSốt nhẹ (37.5 - 38.5°C):\n- Mặc đồ thoáng, mỏng\n- Lau mát bằng nước ấm (KHÔNG dùng nước lạnh/cồn)\n- Cho bú/uống nước nhiều hơn\n- Theo dõi nhiệt độ mỗi 2-4 giờ\n\nSốt vừa-cao (≥ 38.5°C):\n- Dùng Paracetamol: 10-15mg/kg/lần, cách 4-6 giờ\n- Hoặc Ibuprofen (nếu bé > 6 tháng): 5-10mg/kg/lần\n- KHÔNG dùng Aspirin cho trẻ em\n- KHÔNG xen kẽ 2 loại thuốc hạ sốt trừ khi bác sĩ chỉ định\n\n**XỬ LÝ KHI BÉ BỊ SỔ MŨI:**\n- Nhỏ 2-3 giọt nước muối sinh lý 0.9% mỗi bên mũi\n- Hút mũi nhẹ nhàng bằng dụng cụ hút mũi\n- Kê cao đầu khi ngủ (đặt gối dưới nệm, KHÔNG đặt dưới đầu bé)\n- Bật máy tạo ẩm trong phòng\n\n**XỬ LÝ KHI BÉ BỊ HO:**\n- Bé < 1 tuổi: cho bú mẹ nhiều hơn\n- Bé > 1 tuổi: cho uống mật ong pha nước ấm (1/2 thìa cà phê)\n- Không dùng thuốc ho cho bé dưới 6 tuổi nếu không có chỉ định bác sĩ\n\n**DẤU HIỆU CẦN ĐI CẤP CỨU NGAY:**\n- Bé dưới 3 tháng bị sốt ≥ 38°C\n- Sốt > 40°C ở mọi lứa tuổi\n- Sốt kéo dài > 3 ngày không giảm\n- Khó thở, thở nhanh, rút lõm ngực\n- Co giật khi sốt\n- Bé lừ đừ, bỏ bú, da xanh tái\n- Phát ban toàn thân kèm sốt\n\n**Tủ thuốc gia đình cần có:**\n- Nhiệt kế điện tử\n- Paracetamol siro (Efferalgan, Tylenol)\n- Nước muối sinh lý NaCl 0.9%\n- Oresol (gói bù nước)\n- Dụng cụ hút mũi",
    category: 'common_illness',
    source_url: 'https://nhidong.org.vn/xu-ly-sot-tre-em',
    image_url: 'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=800&q=80',
    position: 6
  }
]

health_tips_data.each do |data|
  tip = HealthTip.find_or_initialize_by(title: data[:title])
  tip.assign_attributes(data.merge(published: true))
  tip.save!
  puts "  ✓ #{data[:title]}"
end
puts "✅ Đã tạo #{HealthTip.count} bài viết sức khoẻ!"

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
