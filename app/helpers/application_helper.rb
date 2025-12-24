module ApplicationHelper
  # Lazy load images for better performance
  # Automatically adds loading="lazy" and decoding="async" attributes
  def lazy_image_tag(source, options = {})
    # Don't lazy load images above the fold (first few images)
    # Set eager: true to skip lazy loading for hero images
    unless options.delete(:eager)
      options[:loading] ||= "lazy"
      options[:decoding] ||= "async"
    end

    image_tag(source, options)
  end

  # Optimized image tag for Active Storage attachments
  # Automatically uses appropriate variant based on context
  def optimized_image_tag(attachment, variant_name = :medium, options = {})
    return unless attachment.attached?

    # Define variants (configured in models)
    variant = case variant_name
    when :thumbnail then { resize_to_limit: [200, 200] }
    when :medium then { resize_to_limit: [400, 400] }
    when :large then { resize_to_limit: [800, 800] }
    else { resize_to_limit: [400, 400] }
    end

    # Use lazy loading by default
    options[:loading] ||= "lazy"
    options[:decoding] ||= "async"

    image_tag(attachment.variant(variant), options)
  end

  def calculate_age(birth_date)
    today = Date.today
    years = today.year - birth_date.year
    months = today.month - birth_date.month

    # Điều chỉnh nếu tháng hiện tại nhỏ hơn tháng sinh
    if months < 0
      years -= 1
      months += 12
    end

    # Điều chỉnh nếu ngày hiện tại nhỏ hơn ngày sinh trong tháng
    if today.day < birth_date.day
      months -= 1
      if months < 0
        months += 12
        years -= 1
      end
    end

    [years, months]
  end
end
