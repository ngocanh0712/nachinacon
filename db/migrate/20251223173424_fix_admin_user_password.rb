# frozen_string_literal: true

class FixAdminUserPassword < ActiveRecord::Migration[7.1]
  def up
    # Delete all existing admin users to clean up any corrupted data
    AdminUser.delete_all

    # Create fresh admin user with proper password hash
    AdminUser.create!(
      email: 'admin@nachinacon.info',
      name: 'Admin',
      password: 'ngocanh0712',
      password_confirmation: 'ngocanh0712'
    )

    puts "✓ Admin user recreated: admin@nachinacon.info"
  end

  def down
    # Optional: restore point
    AdminUser.find_by(email: 'admin@nachinacon.info')&.destroy
  end
end
