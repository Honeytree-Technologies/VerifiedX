class Public::AccountsController < Public::ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    @account = Account.where('LOWER(mastodon_handle) = ?', params.[](:handle)&.downcase).first
    self_account = current_account && current_account.mastodon_handle.downcase == params.[](:handle)&.downcase
    if @account
      if @account.removed? && !self_account
        flash[:notice] = "This profile has requested removal and is no longer available. We apologize for any inconvenience caused."
        redirect_to root_path and return
      end

      unless @account.account_type == params[:account_type] || self_account && Account.account_types.include?(params.[](:account_type)&.to_sym)
        redirect_to show_account_path(account_type: @account.account_type, handle: params[:handle]) and return
      end

      @title = @account.name
      @keywords = @account.keywords.to_s.split(',').join(' ')
      @description = Nokogiri::HTML::DocumentFragment.parse(@account.description).text
      @og_image = @account.mastodon_account&.[]('avatar')
    end

    respond_to do |format|
      format.html do
        if current_account && current_account.mastodon_handle.downcase == params.[](:handle)&.downcase
          render action: :edit and return
        end

        render action: :new unless @account
      end
      format.json { render json: { success: @account.present?, account: @account || {} } }
    end
  end

  def check
    @account = Account.where('LOWER(mastodon_handle) = ?', cookies[:loggedIn]).first
    respond_to do |format|
      format.json { render json: { success: @account.present?, account: @account || {} } }
    end
  end

  def create
    redirect_to root_path and return unless cookies[:loggedIn] && check_login

    # TODO: Change team_id to something else
    new_record = false
    account = Account.where('LOWER(mastodon_handle) = ?', params.[](:mastodon_handle)&.downcase).first
    params[:topic_ids] ||= []
    parameters = account_params.merge({ team_id: Team.first.id })
    parameters = parameters.except(:status) unless %w[claimed pending].include? params[:status].to_s
    parameters = parameters.except(:mastodon_handle) if account
    parameters[:hashtags] = params.[](:hashtags)&.split(',')
                              &.map { |hashtag| hashtag.gsub('#', '') }&.join(',')
    parameters[:account_type] = params[:account_type] == 'true' ? 'organizations' : 'people'
    if account
      account.assign_attributes(parameters)
    else
      new_record = true
      account = Account.new(parameters)
    end
    if account.save
      flash[:notice] = if params[:status] == 'claimed'
                         "Verification claim successful. Thank you for joining #{Setting.application_upper_url}!"
                       elsif new_record
                         'Your suggested listing has been received. We appreciate your contribution!'
                       else
                         'Your profile information has been successfully updated.'
                       end
      render json: { success: true }
    else
      flash[:error] = 'We encountered an error. Please check your input and try again. If the problem persists, please contact us for assistance.'
      render json: { success: false }
    end
  end

  def edit
    @account = current_account
    redirect_to root_path unless cookies[:loggedIn] && current_account
  end

  def new
    @account = Account.where('LOWER(mastodon_handle) = ?', params.[](:handle)&.downcase).first
    if @account
      redirect_to show_account_path(account_type: @account.account_type || 'accounts', handle: @account.mastodon_handle) and return
    end

    return if params[:account_type] == 'accounts'

    redirect_to new_account_path(account_type: :accounts, handle: params[:handle])
  end

  def delete
    redirect_to root_path and return unless cookies[:loggedIn]

    @account = current_account
    @account.status = :removed
    @account.request_remove_at = DateTime.now
    @account.save
    redirect_to action: :edit
  end

  def cancel_delete
    redirect_to root_path and return unless cookies[:loggedIn]

    @account = current_account
    @account.status = :pending
    @account.request_remove_at = nil
    @account.save
    redirect_to action: :edit
  end

  def show_statuses
    @statuses = JSON.parse params[:posts]
    respond_to(&:turbo_stream)
  end

  include InviteOnlySupport

  # Make Bullet Train's documentation available at `/docs`.
  include DocumentationSupport

  private

  def account_params
    params.permit(:mastodon_handle, :name,
                  :email,
                  :first_name,
                  :last_name,
                  :phone_number,
                  :region_id,
                  :job_title,
                  :organisation,
                  :organisation_type,
                  :website_url,
                  :blog_url,
                  :show_email,
                  :show_phone,
                  :mastodon_url,
                  :show_location,
                  :status,
                  :account_type,
                  :address,
                  :keywords,
                  :hashtags,
                  urls: [],
                  topic_ids: [])
  end

end
