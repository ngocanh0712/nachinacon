# frozen_string_literal: true

# Pagy initializer file
# See https://ddnexus.github.io/pagy/docs/api/pagy

require 'pagy/extras/overflow'

# Pagy global configuration
Pagy::DEFAULT[:items] = 12
Pagy::DEFAULT[:overflow] = :last_page

# Pagy I18n (if needed for Vietnamese)
# Pagy::I18n.load(locale: 'vi')
