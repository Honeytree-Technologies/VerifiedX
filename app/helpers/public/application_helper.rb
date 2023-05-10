module Public::ApplicationHelper
  include Helpers::Base
  def current_account
    @current_account ||= Account.where('LOWER(mastodon_handle) = ?', cookies[:loggedIn]).first
  end

  def get_mastodon_id(account_json)
    username = account_json["username"]
    domain = account_json["url"].split("://").last.split('/').first
    "@#{username}@#{domain}"
  end

  def sanitize_content(content, url, details)
    sanitized_html = ActionController::Base.helpers.sanitize(content, tags: %w(strong em b i u s a h1 h2 h3 h4 h5 h6 p br))
    doc = Nokogiri::HTML(sanitized_html)
    doc.css('a').each do |a|
      a['target'] = '_blank'
      a['href'] = url
      a['class'] = 'font-medium text-blue-600 dark:text-blue-500 hover:underline'
    end
    if details
      highlights = Nokogiri::HTML::DocumentFragment.parse(details[:content]).css('strong').map { |d| d.text }
      doc.xpath("//text()").each do |node|
        content = node.content
        next if content.blank?

        highlighted_content = highlights.inject(content) do |content, highlight|
          content.gsub(/#{Regexp.escape(highlight)}/i, "<span class=\"bg-yellow-200 dark:bg-yellow-600\">#{highlight}</span>")
        end

        node.replace(highlighted_content)
      end
    end
    doc.to_html
  end

end
