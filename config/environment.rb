# Load the Rails application.
require_relative "application"

# Set secret_key_base from ENV before initialization
if ENV["SECRET_KEY_BASE"].present?
  Rails.application.config.secret_key_base = ENV["SECRET_KEY_BASE"]
end

# Initialize the Rails application.
Rails.application.initialize!
