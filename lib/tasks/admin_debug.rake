# frozen_string_literal: true

namespace :admin do
  desc "Debug admin user state"
  task debug: :environment do
    puts "\n=== Admin User Debug Info ==="

    admin = AdminUser.find_by(email: 'admin@nachinacon.info')

    if admin
      puts "✓ Admin found: #{admin.email}"
      puts "  ID: #{admin.id}"
      puts "  Name: #{admin.name}"
      puts "  Password digest present: #{admin.password_digest.present?}"
      puts "  Password digest length: #{admin.password_digest&.length || 0}"
      puts "  Password digest starts with $2a$: #{admin.password_digest&.start_with?('$2a$') || false}"
      puts "  Password digest value: #{admin.password_digest&.first(20)}..."

      # Try to authenticate with the correct password
      puts "\n  Testing authentication..."
      begin
        result = admin.authenticate('ngocanh0712')
        puts "  ✓ Authentication successful!" if result
        puts "  ✗ Authentication failed (wrong password)" unless result
      rescue => e
        puts "  ✗ Authentication error: #{e.message}"
      end
    else
      puts "✗ Admin not found: admin@nachinacon.info"
    end

    puts "\n=== All Admin Users ==="
    AdminUser.all.each do |a|
      puts "  - #{a.email} (ID: #{a.id})"
    end

    puts "\n=== Database Info ==="
    puts "  Database: #{ActiveRecord::Base.connection.current_database}"
    puts "  Rails env: #{Rails.env}"
  end

  desc "Force recreate admin user"
  task force_recreate: :environment do
    puts "\n=== Force Recreating Admin User ==="

    # Delete ALL admin users
    count = AdminUser.delete_all
    puts "Deleted #{count} admin user(s)"

    # Create new admin
    admin = AdminUser.new(
      email: 'admin@nachinacon.info',
      name: 'Admin'
    )
    admin.password = 'ngocanh0712'
    admin.password_confirmation = 'ngocanh0712'

    if admin.save
      puts "✓ Admin created successfully"
      puts "  Email: #{admin.email}"
      puts "  Password digest: #{admin.password_digest.first(30)}..."

      # Verify it works
      if admin.authenticate('ngocanh0712')
        puts "✓ Password verification successful!"
      else
        puts "✗ Password verification failed!"
      end
    else
      puts "✗ Failed to create admin"
      puts "  Errors: #{admin.errors.full_messages.join(', ')}"
    end
  end
end
