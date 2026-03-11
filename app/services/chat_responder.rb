# frozen_string_literal: true

require 'net/http'
require 'json'

# AI chatbot using Google Gemini Flash API.
# Builds system prompt with baby data from DB, sends user message to Gemini.
# Falls back to simple keyword matching if API key missing or API error.
class ChatResponder
  GEMINI_MODEL = 'gemini-2.0-flash'
  GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/#{GEMINI_MODEL}:generateContent"

  def initialize(message)
    @message = message.to_s.strip
  end

  def respond
    if api_key.present?
      ai_response
    else
      fallback_response
    end
  end

  private

  def api_key
    @api_key ||= ENV['GEMINI_API_KEY'].presence || SiteSetting.get('gemini_api_key').presence
  end

  def baby_name
    @baby_name ||= SiteSetting.get('baby_nickname') || 'Bé'
  end

  # Build system prompt with current baby data context
  def system_prompt
    parts = []
    parts << "Bạn là trợ lý AI dễ thương của #{baby_name}, một em bé Việt Nam."
    parts << "Trả lời bằng tiếng Việt, ngắn gọn, dễ thương, dùng emoji phù hợp."
    parts << "Chỉ trả lời về bé và các chủ đề liên quan (sức khoẻ, dinh dưỡng, phát triển, kỷ niệm)."
    parts << "Nếu câu hỏi không liên quan đến bé, nhẹ nhàng chuyển hướng về bé."
    parts << ""
    parts << "=== THÔNG TIN BÉ ==="
    parts << baby_info
    parts << milestone_info
    parts << journal_info
    parts << memory_info
    parts << growth_info
    parts.compact.join("\n")
  end

  def baby_info
    birth_date = SiteSetting.baby_birth_date
    days = (Date.today - birth_date).to_i
    months = SiteSetting.baby_age_in_months
    years = months / 12
    remaining = months % 12
    age = years > 0 ? "#{years} tuổi #{remaining} tháng" : "#{months} tháng"

    "Tên: #{baby_name}, Sinh: #{birth_date.strftime('%d/%m/%Y')}, Tuổi: #{age} (#{days} ngày)"
  end

  def milestone_info
    recent = Milestone.achieved.order(achieved_at: :desc).limit(5)
    return nil unless recent.any?

    lines = recent.map { |m| "- #{m.name} (#{m.achieved_at.strftime('%d/%m/%Y')})" }
    "Milestone đã đạt:\n#{lines.join("\n")}"
  end

  def journal_info
    journal = DailyJournal.order(date: :desc).first
    return nil unless journal

    parts = ["Nhật ký gần nhất (#{journal.date.strftime('%d/%m/%Y')}): Tâm trạng #{journal.mood_label}"]
    parts << "Ngủ #{journal.sleep_hours}h" if journal.sleep_hours.present?
    parts << "Ăn: #{journal.eat_note}" if journal.eat_note.present?
    parts << "Hoạt động: #{journal.activity_note}" if journal.activity_note.present?
    parts << "Ghi chú: #{journal.note}" if journal.note.present?
    parts.join(', ')
  end

  def memory_info
    total = Memory.count
    photos = Memory.photos.count
    videos = Memory.videos.count
    albums = Album.count
    "Kỷ niệm: #{total} (#{photos} ảnh, #{videos} video), #{albums} album"
  end

  def growth_info
    return nil unless defined?(GrowthRecord)

    record = GrowthRecord.order(recorded_on: :desc).first
    return nil unless record

    parts = ["Số đo gần nhất (#{record.recorded_on.strftime('%d/%m/%Y')}):"]
    parts << "#{record.weight_kg}kg" if record.weight_kg.present?
    parts << "#{record.height_cm}cm" if record.height_cm.present?
    parts.join(' ')
  end

  # Call Gemini Flash API
  def ai_response
    uri = URI("#{GEMINI_URL}?key=#{api_key}")
    body = {
      system_instruction: { parts: [{ text: system_prompt }] },
      contents: [{ parts: [{ text: @message }] }],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 300
      }
    }

    response = Net::HTTP.post(uri, body.to_json, 'Content-Type' => 'application/json')
    data = JSON.parse(response.body)

    text = data.dig('candidates', 0, 'content', 'parts', 0, 'text')

    if text.present?
      { text: text, suggestions: ai_suggestions }
    else
      # API returned empty/error, use fallback
      Rails.logger.warn("Gemini API error: #{data}")
      fallback_response
    end
  rescue StandardError => e
    Rails.logger.error("ChatResponder AI error: #{e.message}")
    fallback_response
  end

  def ai_suggestions
    ['Bé bao nhiêu tuổi?', 'Hôm nay bé thế nào?', 'Milestone gần nhất?']
  end

  def fallback_response
    {
      text: "Xin chào! Mình là trợ lý của #{baby_name} 👶 Hiện tại chưa kết nối AI. Vui lòng cấu hình Gemini API key trong Admin > Settings.",
      suggestions: ['Bé bao nhiêu tuổi?', 'Hôm nay bé thế nào?']
    }
  end
end
