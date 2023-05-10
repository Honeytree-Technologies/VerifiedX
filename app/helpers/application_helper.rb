module ApplicationHelper
  include Helpers::Base

  def current_theme
    :mastodon
  end

  def public_image_width_for_height(filename, target_height)
    source_width, source_height = FastImage.size("#{Rails.root}/public/#{filename}")
    ratio = source_width.to_f / source_height.to_f
    (target_height * ratio).to_i
  end

  def public_email_image_tag(image, **options)
    image_underscore = image.tr("-", "_")
    attachments.inline[image_underscore] = File.read(Rails.root.join("public/#{image}"))
    image_tag attachments.inline[image_underscore].url, **options
  end

  def format_integer(number)
    number = number.to_i
    if number >= 1000 && number < 1000000
      "#{(number / 1000.0).round(1)}k"
    elsif number >= 1000000 && number < 1000000000
      "#{(number / 1000000.0).round(1)}m"
    elsif number >= 1000000000
      "#{(number / 1000000000.0).round(1)}b"
    else
      number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end
  end

  def time_diff_in_hours(datetime)
    time_diff_in_hours = datetime ? ((datetime - DateTime.now).round / 60).round / 60 : 0
    time_diff_in_hours = 0 if time_diff_in_hours.negative?
    "#{time_diff_in_hours} #{'hour'.pluralize(time_diff_in_hours)} remaining"
  end
end
