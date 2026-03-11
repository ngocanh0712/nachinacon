# frozen_string_literal: true

class DailyJournal < ApplicationRecord
  # Mood enum: maps integer values to mood states
  MOODS = {
    'happy' => 0,
    'neutral' => 1,
    'fussy' => 2,
    'sick' => 3
  }.freeze

  MOOD_LABELS = {
    'happy' => 'Vui vẻ',
    'neutral' => 'Bình thường',
    'fussy' => 'Quấy khóc',
    'sick' => 'Ốm'
  }.freeze

  MOOD_EMOJIS = {
    'happy' => '😊',
    'neutral' => '😐',
    'fussy' => '😢',
    'sick' => '🤒'
  }.freeze

  MOOD_COLORS = {
    'happy' => '#10B981',
    'neutral' => '#6B7280',
    'fussy' => '#F59E0B',
    'sick' => '#EF4444'
  }.freeze

  enum :mood, MOODS

  validates :date, presence: true, uniqueness: true
  validates :mood, presence: true

  scope :ordered, -> { order(date: :desc) }
  scope :by_month, ->(year, month) {
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    where(date: start_date..end_date)
  }
  scope :recent, -> { ordered.limit(10) }

  def mood_key
    self.class.moods.key(mood_before_type_cast) || 'neutral'
  end

  def mood_label
    MOOD_LABELS[mood_key] || 'Bình thường'
  end

  def mood_emoji
    MOOD_EMOJIS[mood_key] || '😐'
  end

  def mood_color
    MOOD_COLORS[mood_key] || '#6B7280'
  end

  # Short preview for calendar cell
  def preview_text
    [eat_note, activity_note, note].compact_blank.first&.truncate(40) || ''
  end
end
