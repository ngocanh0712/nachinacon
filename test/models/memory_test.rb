# frozen_string_literal: true

require "test_helper"

class MemoryTest < ActiveSupport::TestCase
  def setup
    @memory = Memory.new(
      title: "Test Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
  end

  # Basic Memory Creation Tests
  test "should create memory with valid attributes" do
    assert @memory.valid?
    assert @memory.save
  end

  test "should require title" do
    @memory.title = nil
    assert_not @memory.valid?
    assert @memory.errors[:title].any?
  end

  test "should require taken_at" do
    @memory.taken_at = nil
    assert_not @memory.valid?
    assert @memory.errors[:taken_at].any?
  end

  test "should require memory_type" do
    @memory.memory_type = nil
    assert_not @memory.valid?
    assert @memory.errors[:memory_type].any?
  end

  test "should require age_group" do
    @memory.age_group = nil
    assert_not @memory.valid?
    assert @memory.errors[:age_group].any?
  end

  test "should validate memory_type inclusion" do
    @memory.memory_type = "invalid_type"
    assert_not @memory.valid?
    assert @memory.errors[:memory_type].any?
  end

  test "should accept photo as memory_type" do
    @memory.memory_type = "photo"
    assert @memory.valid?
  end

  test "should accept video as memory_type" do
    @memory.memory_type = "video"
    assert @memory.valid?
  end

  test "should validate age_group inclusion" do
    @memory.age_group = "invalid_age"
    assert_not @memory.valid?
    assert @memory.errors[:age_group].any?
  end

  # Album Association Tests
  test "should have many albums through album_memories" do
    memory = Memory.create!(@memory.attributes)
    album1 = Album.create!(name: "Album 1")
    album2 = Album.create!(name: "Album 2")

    AlbumMemory.create!(album: album1, memory: memory)
    AlbumMemory.create!(album: album2, memory: memory)

    assert memory.albums.include?(album1)
    assert memory.albums.include?(album2)
    assert_equal 2, memory.albums.count
  end

  test "should have many album_memories" do
    memory = Memory.create!(@memory.attributes)
    album = Album.create!(name: "Test Album")
    
    album_memory = AlbumMemory.create!(album: album, memory: memory)
    
    assert memory.album_memories.include?(album_memory)
  end

  test "should destroy associated album_memories when destroyed" do
    memory = Memory.create!(@memory.attributes)
    album = Album.create!(name: "Test Album")
    album_memory = AlbumMemory.create!(album: album, memory: memory)

    assert_difference("AlbumMemory.count", -1) do
      memory.destroy
    end
  end

  # Type Helper Methods
  test "should return true for photo? when memory_type is photo" do
    photo = Memory.create!(
      title: "Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    assert photo.photo?
    assert_not photo.video?
  end

  test "should return true for video? when memory_type is video" do
    video = Memory.create!(
      title: "Video",
      taken_at: Time.current,
      memory_type: "video",
      age_group: "0-3m"
    )
    assert video.video?
    assert_not video.photo?
  end

  # Scope Tests
  test "photos scope should return only photos" do
    photo = Memory.create!(
      title: "Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    video = Memory.create!(
      title: "Video",
      taken_at: Time.current,
      memory_type: "video",
      age_group: "0-3m"
    )

    photos = Memory.photos
    assert photos.include?(photo)
    assert_not photos.include?(video)
  end

  test "videos scope should return only videos" do
    photo = Memory.create!(
      title: "Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    video = Memory.create!(
      title: "Video",
      taken_at: Time.current,
      memory_type: "video",
      age_group: "0-3m"
    )

    videos = Memory.videos
    assert videos.include?(video)
    assert_not videos.include?(photo)
  end

  test "by_age_group scope should filter by age_group" do
    memory1 = Memory.create!(
      title: "Young Memory",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    memory2 = Memory.create!(
      title: "Older Memory",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "1-2y"
    )

    young_memories = Memory.by_age_group("0-3m")
    assert young_memories.include?(memory1)
    assert_not young_memories.include?(memory2)
  end

  test "recent scope should order by taken_at descending" do
    old_memory = Memory.create!(
      title: "Old",
      taken_at: 1.week.ago,
      memory_type: "photo",
      age_group: "0-3m"
    )
    new_memory = Memory.create!(
      title: "New",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )

    memories = Memory.recent
    assert_equal new_memory.id, memories.first.id
    assert_equal old_memory.id, memories.last.id
  end

  test "chronological scope should order by taken_at ascending" do
    old_memory = Memory.create!(
      title: "Old",
      taken_at: 1.week.ago,
      memory_type: "photo",
      age_group: "0-3m"
    )
    new_memory = Memory.create!(
      title: "New",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )

    memories = Memory.chronological
    assert_equal old_memory.id, memories.first.id
    assert_equal new_memory.id, memories.last.id
  end

  # Age Group Constants Tests
  test "should have valid age groups" do
    expected_groups = %w[0-3m 3-6m 6-12m 1-2y 2-3y]
    assert_equal expected_groups, Memory::AGE_GROUPS.map(&:last)
  end

  test "should have valid memory types" do
    expected_types = %w[photo video]
    assert_equal expected_types, Memory::MEMORY_TYPES
  end

  # Media Attachment Tests
  test "should attach media file" do
    memory = Memory.create!(@memory.attributes)
    file = fixture_file_upload("test_image.jpg", "image/jpeg")
    memory.media.attach(file)

    assert memory.media.attached?
  end
end
