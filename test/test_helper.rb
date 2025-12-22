# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Setup all fixtures before each test
    # fixtures :all

    # Helper for file uploads in tests
    def fixture_file_upload(filename, mime_type)
      Rack::Test::UploadedFile.new(
        Rails.root.join("test", "fixtures", "files", filename),
        mime_type
      )
    end
  end
end
