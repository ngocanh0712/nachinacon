# Temporary debug - remove after fixing
Rails.logger.info "=" * 50
Rails.logger.info "DATABASE DEBUG:"
Rails.logger.info "RAILS_ENV: #{Rails.env}"
Rails.logger.info "DATABASE_URL present: #{ENV['DATABASE_URL'].present?}"
Rails.logger.info "DATABASE_URL value: #{ENV['DATABASE_URL']&.gsub(/:[^:@]+@/, ':***@')}"
Rails.logger.info "MYSQLHOST: #{ENV['MYSQLHOST']}"
Rails.logger.info "=" * 50
