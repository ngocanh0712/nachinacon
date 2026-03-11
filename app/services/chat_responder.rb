# frozen_string_literal: true

# Stateless chatbot that answers questions about baby using app data.
# Matches Vietnamese keywords in user message and queries DB for answers.
class ChatResponder
  # Vietnamese keywords with non-diacritic variants for flexible matching
  GREETING_KEYWORDS = %w[chào chao hello hey alo xin chào].freeze
  AGE_KEYWORDS = %w[tuổi tuoi tháng thang age old].freeze
  MILESTONE_KEYWORDS = %w[milestone mốc moc first biết biet].freeze
  PHOTO_KEYWORDS = %w[ảnh anh hình hinh photo memory kỷ niệm ky niem].freeze
  JOURNAL_KEYWORDS = %w[hôm nay hom nay today nhật ký nhat ky journal mood].freeze
  ALBUM_KEYWORDS = %w[album].freeze
  GROWTH_KEYWORDS = %w[cân nặng can nang chiều cao chieu cao growth].freeze
  HEALTH_KEYWORDS = %w[sức khỏe suc khoe sức khoẻ health].freeze
  RECIPE_KEYWORDS = %w[món ăn mon an recipe ẩm thực am thuc nấu nau dinh dưỡng].freeze
  HELP_KEYWORDS = %w[giúp giup help hướng dẫn huong dan].freeze

  def initialize(message)
    @message = message.to_s.downcase.strip
  end

  def respond
    # Check specific topics first, greeting last (to avoid false positives)
    return age_response if matches?(AGE_KEYWORDS)
    return journal_response if matches?(JOURNAL_KEYWORDS)
    return milestone_response if matches?(MILESTONE_KEYWORDS)
    return photo_response if matches?(PHOTO_KEYWORDS)
    return album_response if matches?(ALBUM_KEYWORDS)
    return growth_response if matches?(GROWTH_KEYWORDS)
    return health_response if matches?(HEALTH_KEYWORDS)
    return recipe_response if matches?(RECIPE_KEYWORDS)
    return help_response if matches?(HELP_KEYWORDS)
    return greeting_response if matches?(GREETING_KEYWORDS)

    fallback_response
  end

  private

  def matches?(keywords)
    msg = @message.encode('UTF-8', invalid: :replace, undef: :replace)
    keywords.any? { |kw| msg.include?(kw.encode('UTF-8')) }
  end

  def baby_name
    @baby_name ||= SiteSetting.get('baby_nickname') || 'Bé'
  end

  def greeting_response
    {
      text: "Xin chào! Mình là trợ lý của #{baby_name} 👶 Bạn muốn biết gì về bé nào?",
      suggestions: ['Bé bao nhiêu tuổi?', 'Hôm nay bé thế nào?', 'Milestone gần nhất?']
    }
  end

  def age_response
    birth_date = SiteSetting.baby_birth_date
    days = (Date.today - birth_date).to_i
    months = SiteSetting.baby_age_in_months
    years = months / 12
    remaining_months = months % 12

    age_text = if years > 0
                 "#{years} tuổi #{remaining_months} tháng"
               else
                 "#{months} tháng"
               end

    {
      text: "#{baby_name} sinh ngày #{birth_date.strftime('%d/%m/%Y')}, hiện được #{age_text} (#{days} ngày) rồi! 🎂",
      suggestions: ['Milestone gần nhất?', 'Bé có bao nhiêu ảnh?']
    }
  end

  def journal_response
    journal = DailyJournal.where(date: Date.today).first

    if journal
      parts = ["Hôm nay #{baby_name} #{journal.mood_emoji} #{journal.mood_label}."]
      parts << "Ngủ #{journal.sleep_hours} giờ." if journal.sleep_hours.present?
      parts << "Ăn: #{journal.eat_note}" if journal.eat_note.present?
      parts << "Hoạt động: #{journal.activity_note}" if journal.activity_note.present?
      parts << journal.note if journal.note.present?

      { text: parts.join(' '), suggestions: ['Bé bao nhiêu tuổi?', 'Milestone gần nhất?'] }
    else
      { text: "Hôm nay chưa có nhật ký cho #{baby_name}. Ba mẹ chưa ghi chép gì hôm nay 📝", suggestions: ['Bé bao nhiêu tuổi?', 'Bé có bao nhiêu ảnh?'] }
    end
  end

  def milestone_response
    recent = Milestone.achieved.order(achieved_at: :desc).limit(3)
    pending = Milestone.pending.limit(3)

    if recent.any?
      lines = recent.map { |m| "⭐ #{m.name} (#{m.achieved_at.strftime('%d/%m/%Y')})" }
      text = "Những mốc gần nhất của #{baby_name}:\n#{lines.join("\n")}"
      text += "\n\nĐang chờ: #{pending.map(&:name).join(', ')}" if pending.any?
      { text: text, suggestions: ['Bé bao nhiêu tuổi?', 'Bé có bao nhiêu ảnh?'] }
    else
      { text: "#{baby_name} chưa có milestone nào được ghi nhận.", suggestions: ['Bé bao nhiêu tuổi?'] }
    end
  end

  def photo_response
    total = Memory.count
    photos = Memory.photos.count
    videos = Memory.videos.count
    albums = Album.count

    {
      text: "#{baby_name} có tổng cộng #{total} kỷ niệm (#{photos} ảnh, #{videos} video) trong #{albums} album 📸",
      suggestions: ['Milestone gần nhất?', 'Hôm nay bé thế nào?']
    }
  end

  def album_response
    albums = Album.with_memories.recent.limit(5)
    if albums.any?
      lines = albums.map { |a| "📁 #{a.name} (#{a.memories.count} ảnh)" }
      { text: "Albums của #{baby_name}:\n#{lines.join("\n")}", suggestions: ['Bé có bao nhiêu ảnh?'] }
    else
      { text: "Chưa có album nào.", suggestions: ['Bé bao nhiêu tuổi?'] }
    end
  end

  def growth_response
    record = GrowthRecord.order(recorded_on: :desc).first if defined?(GrowthRecord)

    if record
      parts = ["Số đo gần nhất của #{baby_name} (#{record.recorded_on.strftime('%d/%m/%Y')}):"]
      parts << "Cân nặng: #{record.weight_kg} kg" if record.weight_kg.present?
      parts << "Chiều cao: #{record.height_cm} cm" if record.height_cm.present?
      parts << "Vòng đầu: #{record.head_cm} cm" if record.head_cm.present?
      { text: parts.join("\n"), suggestions: ['Bé bao nhiêu tuổi?', 'Milestone gần nhất?'] }
    else
      { text: "Chưa có dữ liệu tăng trưởng cho #{baby_name}.", suggestions: ['Bé bao nhiêu tuổi?'] }
    end
  end

  def health_response
    tips = HealthTip.published.ordered.limit(3)
    if tips.any?
      lines = tips.map { |t| "#{t.category_icon} #{t.title}" }
      { text: "Bài viết sức khoẻ mới nhất:\n#{lines.join("\n")}", suggestions: ['Món ăn cho bé?', 'Bé bao nhiêu tuổi?'] }
    else
      { text: "Chưa có bài viết sức khoẻ nào.", suggestions: ['Bé bao nhiêu tuổi?'] }
    end
  end

  def recipe_response
    recipes = Recipe.published.ordered.limit(3)
    if recipes.any?
      lines = recipes.map { |r| "🍽️ #{r.title}" }
      { text: "Công thức ẩm thực mới nhất:\n#{lines.join("\n")}", suggestions: ['Sức khoẻ bé?', 'Bé bao nhiêu tuổi?'] }
    else
      { text: "Chưa có công thức ẩm thực nào.", suggestions: ['Bé bao nhiêu tuổi?'] }
    end
  end

  def help_response
    {
      text: "Bạn có thể hỏi mình về:\n• Bé bao nhiêu tuổi?\n• Hôm nay bé thế nào?\n• Milestone gần nhất?\n• Bé có bao nhiêu ảnh?\n• Albums của bé?\n• Cân nặng chiều cao?\n• Sức khoẻ mẹ và bé?\n• Món ăn cho bé?",
      suggestions: ['Bé bao nhiêu tuổi?', 'Hôm nay bé thế nào?', 'Milestone gần nhất?']
    }
  end

  def fallback_response
    {
      text: "Mình chưa hiểu câu hỏi này 😅 Thử hỏi về tuổi, milestone, ảnh, nhật ký, hoặc gõ \"giúp\" để xem danh sách câu hỏi nhé!",
      suggestions: ['Giúp mình', 'Bé bao nhiêu tuổi?', 'Hôm nay bé thế nào?']
    }
  end
end
