# frozen_string_literal: true

require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  def setup
    @album = Album.new(name: "First Year")
  end

  # Album Creation with Validation Tests
  test "should create album with valid attributes" do
    assert @album.valid?
    assert @album.save
  end

  test "should not save album without a name" do
    @album.name = nil
    assert_not @album.valid?
    assert @album.errors[:name].any?
  end

  test "should not save album with blank name" do
    @album.name = ""
    assert_not @album.valid?
    assert @album.errors[:name].any?
  end

  test "should save album with valid name" do
    @album.name = "Spring Memories"
    assert @album.save
    assert_equal "Spring Memories", @album.reload.name
  end

  # AlbumMemory Join Table Tests
  test "should add memories to album through album_memories" do
    album = Album.create!(name: "Test Album")
    memory = Memory.create!(
      title: "First Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )

    album_memory = AlbumMemory.new(album: album, memory: memory)
    assert album_memory.save

    assert album.album_memories.include?(album_memory)
    assert album.memories.include?(memory)
  end

  test "should not allow duplicate memory in same album" do
    album = Album.create!(name: "Test Album")
    memory = Memory.create!(
      title: "First Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )

    AlbumMemory.create!(album: album, memory: memory)
    duplicate = AlbumMemory.new(album: album, memory: memory)

    assert_not duplicate.valid?
    assert duplicate.errors[:album_id].any?
  end

  # Memory-Album Many-to-Many Relationship Tests
  test "should access albums through memory" do
    album1 = Album.create!(name: "Album 1")
    album2 = Album.create!(name: "Album 2")
    memory = Memory.create!(
      title: "Shared Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )

    AlbumMemory.create!(album: album1, memory: memory)
    AlbumMemory.create!(album: album2, memory: memory)

    assert memory.albums.include?(album1)
    assert memory.albums.include?(album2)
    assert_equal 2, memory.albums.count
  end

  test "should access memories through album" do
    album = Album.create!(name: "Multi-Memory Album")
    memory1 = Memory.create!(
      title: "Photo 1",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    memory2 = Memory.create!(
      title: "Video 1",
      taken_at: Time.current,
      memory_type: "video",
      age_group: "3-6m"
    )

    AlbumMemory.create!(album: album, memory: memory1)
    AlbumMemory.create!(album: album, memory: memory2)

    assert album.memories.include?(memory1)
    assert album.memories.include?(memory2)
    assert_equal 2, album.memories.count
  end

  # Album.memory_count Method Tests
  test "should return 0 for album with no memories" do
    album = Album.create!(name: "Empty Album")
    assert_equal 0, album.memory_count
  end

  test "should return correct count of memories in album" do
    album = Album.create!(name: "Counting Album")
    
    3.times do |i|
      memory = Memory.create!(
        title: "Memory #{i}",
        taken_at: Time.current,
        memory_type: "photo",
        age_group: "0-3m"
      )
      AlbumMemory.create!(album: album, memory: memory)
    end

    assert_equal 3, album.memory_count
  end

  test "should update memory_count after adding memory" do
    album = Album.create!(name: "Dynamic Album")
    assert_equal 0, album.memory_count

    memory = Memory.create!(
      title: "New Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    AlbumMemory.create!(album: album, memory: memory)

    assert_equal 1, album.memory_count
  end

  test "should update memory_count after removing memory" do
    album = Album.create!(name: "Remove Album")
    memory = Memory.create!(
      title: "Photo to Remove",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    AlbumMemory.create!(album: album, memory: memory)
    assert_equal 1, album.memory_count

    album.album_memories.destroy_all
    assert_equal 0, album.memory_count
  end

  # Scope Tests
  test "with_memories scope should include memories" do
    album = Album.create!(name: "Scope Test Album")
    memory = Memory.create!(
      title: "Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    AlbumMemory.create!(album: album, memory: memory)

    result = Album.with_memories
    assert result.include?(album)
  end

  test "recent scope should order by created_at descending" do
    album1 = Album.create!(name: "Old Album")
    album2 = Album.create!(name: "New Album")

    albums = Album.recent
    assert_equal album2.id, albums.first.id
    assert_equal album1.id, albums.last.id
  end

  # Dependent Destroy Tests
  test "should destroy album_memories when album is destroyed" do
    album = Album.create!(name: "Album to Destroy")
    memory = Memory.create!(
      title: "Photo",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
    album_memory = AlbumMemory.create!(album: album, memory: memory)

    assert_difference("AlbumMemory.count", -1) do
      album.destroy
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      album_memory.reload
    end
  end

  # Cover Photo Tests
  test "should attach cover_photo" do
    album = Album.create!(name: "Album with Cover")
    file = fixture_file_upload("test_image.jpg", "image/jpeg")
    album.cover_photo.attach(file)

    assert album.cover_photo.attached?
  end
end
