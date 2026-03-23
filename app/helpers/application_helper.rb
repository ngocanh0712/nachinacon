module ApplicationHelper
  include Pagy::Frontend

  # Lazy load images - adds loading="lazy" and decoding="async"
  # Set eager: true for above-the-fold images
  def lazy_image_tag(source, options = {})
    unless options.delete(:eager)
      options[:loading] ||= "lazy"
      options[:decoding] ||= "async"
    end
    image_tag(source, options)
  end

  # Optimized image tag for Active Storage attachments
  # Uses original image by default, CSS handles sizing
  def optimized_image_tag(attachment, variant_name = :medium, options = {})
    return unless attachment.attached?
    use_original = options.delete(:use_original) != false
    options[:loading] ||= "lazy"
    options[:decoding] ||= "async"

    if use_original
      image_tag(attachment, options)
    else
      variant = case variant_name
      when :thumbnail then { resize_to_limit: [200, 200], quality: 90 }
      when :medium then { resize_to_limit: [400, 400], quality: 90 }
      when :large then { resize_to_limit: [800, 800], quality: 90 }
      else { resize_to_limit: [400, 400], quality: 90 }
      end
      image_tag(attachment.variant(variant), options)
    end
  end

  # Transform Cloudinary URLs with width/quality/format optimization
  # Returns original URL if not a Cloudinary URL
  def cloudinary_url(url, width: nil)
    return url if url.blank?
    return url unless url.include?('cloudinary.com') || url.include?('res.cloudinary')

    # Insert transforms before /upload/ or after existing transforms
    transforms = "f_auto,q_auto"
    transforms += ",w_#{width}" if width
    url.sub(%r{/upload/(?:v\d+/)?}, "/upload/#{transforms}/")
  end

  # Cloudinary-optimized image tag for URL-based images
  # Adds lazy loading + Cloudinary transforms automatically
  def cloudinary_image_tag(url, options = {})
    width = options.delete(:cloudinary_width)
    unless options.delete(:eager)
      options[:loading] ||= "lazy"
      options[:decoding] ||= "async"
    end
    image_tag(cloudinary_url(url, width: width), options)
  end

  def calculate_age_at(birth_date, target_date)
    years = target_date.year - birth_date.year
    months = target_date.month - birth_date.month
    if months < 0
      years -= 1
      months += 12
    end
    if target_date.day < birth_date.day
      months -= 1
      if months < 0
        months += 12
        years -= 1
      end
    end
    [years, months]
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
