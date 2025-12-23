# frozen_string_literal: true

namespace :admin do
  desc "Reset admin user credentials"
  task reset: :environment do
    puts "Resetting admin user..."

    # Delete old admin if exists
    old_admin = AdminUser.find_by(email: 'admin@nachinacon.com')
    if old_admin
      old_admin.destroy
      puts "✓ Deleted old admin: admin@nachinacon.com"
    end

    # Create or update new admin
    admin = AdminUser.find_or_initialize_by(email: 'admin@nachinacon.info')
    admin.name = 'Admin'
    admin.password = 'ngocanh0712'
    admin.password_confirmation = 'ngocanh0712'

    if admin.save
      puts "✓ Admin user created/updated successfully"
      puts "  Email: admin@nachinacon.info"
      puts "  Password: ngocanh0712"
    else
      puts "✗ Failed to create admin user"
      puts "  Errors: #{admin.errors.full_messages.join(', ')}"
    end
  end

  desc "List all admin users"
  task list: :environment do
    puts "Admin users in database:"
    AdminUser.all.each do |admin|
      puts "  - #{admin.email} (#{admin.name})"
      puts "    Password digest present: #{admin.password_digest.present?}"
      puts "    Password digest valid: #{admin.password_digest&.start_with?('$2a$') || false}"
    end
  end
end
