# frozen_string_literal: true

class Public::HomeController < Public::ApplicationController
  # Redirect `/` to either `ENV["MARKETING_SITE_URL"]` or the sign-in page.
  # If you'd like to customize the action for `/`, you can remove this and define `def index ... end ` below.
  # include RootRedirect
  def index
    @stamp = params[:stamp] || SecureRandom.random_number.to_s[2..20].to_i
    filter = 'status in (1, 3, 4)'
    if params[:topic].present?
      @topics = Topic.where(id: params[:topic].split(',')).order(:name)
      filter += " and accounts_topics.topic_id in (#{@topics.ids.join(',')})" if @topics.any?
    end
    if params[:search].present?
      filter += ' and (accounts.name ILIKE :search or accounts.mastodon_handle ILIKE :search' \
                  ' or keywords ILIKE :search or hashtags ILIKE :search or mastodon_account->>\'note\' ILIKE :search' \
                  ' or organisation ILIKE :search)'
    end

    seed_val = Account.connection.quote("0.#{@stamp}".to_f)
    Account.connection.execute("select setseed(#{seed_val})")
    @pagy, @accounts = pagy(Account.left_joins(:topics).
      where(filter, search: "%#{params[:search].strip.gsub('#', '') if params[:search]}%").
      group(:id).order(Arel.sql('status desc, RANDOM()')),
                          params: { stamp: @stamp, search: params[:search], topic: params[:topic] },
                          page_param: :accounts_page, link_extra: 'data-action="public--search#pagy" data-turbo-stream')
  end

  def news
    redirect_to action: :feed, search: params[:search]
  end

  def regions
    filter = 'name ilike :search'
    filter += ' and country_id = :country' if params[:country].to_i.positive?
    @regions = Region.where(filter, search: "%#{params[:q]}%", country: params[:country].to_i)
  end

  def countries
    @countries = Country.where('name ilike :search', search: "%#{params[:q]}%")
  end

  def privacy

  end

  def terms

  end

  def about

  end

  def faq

  end

  # Allow your application to disable public sign-ups and be invitation only.
  include InviteOnlySupport

  # Make Bullet Train's documentation available at `/docs`.
  include DocumentationSupport

end
