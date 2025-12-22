# frozen_string_literal: true

require "test_helper"

class AlbumMemoryTest < ActiveSupport::TestCase
  def setup
    @album = Album.create!(name: "Test Album")
    @memory = Memory.create!(
      title: "Test Memory",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "0-3m"
    )
  end

  # AlbumMemory Creation Tests
  test "should create album_memory with valid attributes" do
    album_memory = AlbumMemory.new(album: @album, memory: @memory)
    assert album_memory.valid?
    assert album_memory.save
  end

  test "should require album_id" do
    album_memory = AlbumMemory.new(memory: @memory)
    assert_not album_memory.valid?
  end

  test "should require memory_id" do
    album_memory = AlbumMemory.new(album: @album)
    assert_not album_memory.valid?
  end

  # Join Table Association Tests
  test "should belong to album" do
    album_memory = AlbumMemory.create!(album: @album, memory: @memory)
    assert_equal @album.id, album_memory.album_id
    assert_equal @album, album_memory.album
  end

  test "should belong to memory" do
    album_memory = AlbumMemory.create!(album: @album, memory: @memory)
    assert_equal @memory.id, album_memory.memory_id
    assert_equal @memory, album_memory.memory
  end

  # Uniqueness Constraint Tests
  test "should not allow duplicate album_memory combination" do
    AlbumMemory.create!(album: @album, memory: @memory)
    duplicate = AlbumMemory.new(album: @album, memory: @memory)

    assert_not duplicate.valid?
    assert duplicate.errors[:album_id].any?
  end

  test "should allow same memory in different albums" do
    album2 = Album.create!(name: "Different Album")
    
    album_memory1 = AlbumMemory.create!(album: @album, memory: @memory)
    album_memory2 = AlbumMemory.new(album: album2, memory: @memory)

    assert album_memory1.valid?
    assert album_memory2.valid?
    assert album_memory2.save
  end

  test "should allow same album with different memories" do
    memory2 = Memory.create!(
      title: "Second Memory",
      taken_at: Time.current,
      memory_type: "video",
      age_group: "3-6m"
    )

    album_memory1 = AlbumMemory.create!(album: @album, memory: @memory)
    album_memory2 = AlbumMemory.new(album: @album, memory: memory2)

    assert album_memory1.valid?
    assert album_memory2.valid?
    assert album_memory2.save
  end

  # Dependent Destroy Tests
  test "should be destroyed when album is destroyed" do
    album_memory = AlbumMemory.create!(album: @album, memory: @memory)
    album_id = @album.id
    album_memory_id = album_memory.id

    @album.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      AlbumMemory.find(album_memory_id)
    end
  end

  test "should persist when memory is destroyed" do
    album_memory = AlbumMemory.create!(album: @album, memory: @memory)
    
    @memory.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      album_memory.reload
    end
  end

  # Query Tests
  test "should find album_memories by album_id" do
    memory2 = Memory.create!(
      title: "Another Memory",
      taken_at: Time.current,
      memory_type: "photo",
      age_group: "3-6m"
    )
    
    AlbumMemory.create!(album: @album, memory: @memory)
    AlbumMemory.create!(album: @album, memory: memory2)

    album_memories = AlbumMemory.where(album_id: @album.id)
    assert_equal 2, album_memories.count
  end

  test "should find album_memories by memory_id" do
    album2 = Album.create!(name: "Another Album")
    
    AlbumMemory.create!(album: @album, memory: @memory)
    AlbumMemory.create!(album: album2, memory: @memory)

    album_memories = AlbumMemory.where(memory_id: @memory.id)
    assert_equal 2, album_memories.count
  end
end
