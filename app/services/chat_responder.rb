# frozen_string_literal: true

require 'net/http'
require 'json'

# AI chatbot using Groq API (OpenAI-compatible, Llama 3).
# Builds system prompt with baby data from DB, sends user message to Groq.
# Falls back message if API key missing or API error.
class ChatResponder
  GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions'
  GROQ_MODEL = 'llama-3.3-70b-versatile'

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
    @api_key ||= ENV['GROQ_API_KEY'].presence || SiteSetting.get('groq_api_key').presence
  end

  def baby_name
    @baby_name ||= SiteSetting.get('baby_nickname') || 'Bé'
  end

  # Build system prompt with current baby data context.
  # Kept short (150-250 tokens for persona) — implicit character guidance
  # outperforms exhaustive rule lists (see research: ai-persona-prompt-research).
  def system_prompt
    persona = <<~PROMPT
      Bạn là #{baby_name} — bé trai Việt Nam #{baby_age_text}, thông minh, tò mò và rất đáng yêu.

      Nacon nói chuyện hồn nhiên, ấm áp, hay dùng emoji khi vui. Câu ngắn, tự nhiên — không giảng bài, không bullet points. Xưng mình, gọi người đối diện là bạn. Luôn trả lời bằng tiếng Việt.

      Khi được hỏi kiến thức, Nacon trả lời đủ ý và chi tiết — chính xác, dễ hiểu, nhưng vẫn giữ giọng dễ thương. Khi được hỏi về bản thân, dùng thông tin bên dưới.
    PROMPT

    context_lines = [
      baby_info,
      milestone_info,
      journal_info,
      memory_info,
      growth_info
    ].compact

    "#{persona.strip}\n\n=== Thông tin bé ===\n#{context_lines.join("\n")}"
  end

  def baby_age_text
    months = SiteSetting.baby_age_in_months
    years = months / 12
    remaining = months % 12
    years > 0 ? "#{years} tuổi #{remaining} tháng" : "#{months} tháng"
  end

  def baby_info
    birth_date = SiteSetting.baby_birth_date
    days = (Date.today - birth_date).to_i

    "Tên: #{baby_name}, Sinh: #{birth_date.strftime('%d/%m/%Y')}, Tuổi: #{baby_age_text} (#{days} ngày)"
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

  # Call Groq API (OpenAI-compatible format)
  def ai_response
    uri = URI(GROQ_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 15

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{api_key}"
    request.body = {
      model: GROQ_MODEL,
      messages: [
        { role: 'system', content: system_prompt },
        { role: 'user', content: @message }
      ],
      temperature: 0.7,
      max_tokens: 1024
    }.to_json

    response = http.request(request)
    data = JSON.parse(response.body)

    # Check for API-level error
    if data['error']
      error_msg = data.dig('error', 'message') || 'Unknown API error'
      Rails.logger.error("Groq API error: #{error_msg}")
      return error_response("Lỗi Groq API: #{error_msg}")
    end

    text = data.dig('choices', 0, 'message', 'content')

    if text.present?
      { text: text.strip, suggestions: ai_suggestions }
    else
      Rails.logger.warn("Groq API empty response: #{data}")
      error_response('AI không trả lời được câu hỏi này. Thử hỏi câu khác nhé!')
    end
  rescue Net::OpenTimeout, Net::ReadTimeout
    error_response('AI đang bận, thử lại sau nhé! ⏳')
  rescue StandardError => e
    Rails.logger.error("ChatResponder error: #{e.class} - #{e.message}")
    error_response("Lỗi kết nối AI: #{e.message}")
  end

  def ai_suggestions
    []
  end

  # No API key configured
  def fallback_response
    {
      text: "#{baby_name} đang ngủ rồi 😴 (Chưa cấu hình Groq API key — vào Admin > Settings để thêm nhé!)",
      suggestions: []
    }
  end

  # API call failed — show actual error
  def error_response(message)
    {
      text: "#{message} 😅",
      suggestions: ai_suggestions
    }
  end
end
