ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# Debug: Print database env vars at boot
puts "=" * 50
puts "BOOT DEBUG:"
puts "RAILS_ENV: #{ENV['RAILS_ENV']}"
puts "DATABASE_URL present: #{!ENV['DATABASE_URL'].nil? && !ENV['DATABASE_URL'].empty?}"
puts "DATABASE_URL: #{ENV['DATABASE_URL']&.gsub(/:[^:@]+@/, ':***@')}"
puts "MYSQLHOST: #{ENV['MYSQLHOST']}"
puts "=" * 50

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
