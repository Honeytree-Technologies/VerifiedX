class Account::AccountsController < Account::ApplicationController
  account_load_and_authorize_resource :account, through: :team, through_association: :accounts
  before_action :set_params, only: [:create, :update]

  # GET /account/teams/:team_id/accounts
  # GET /account/teams/:team_id/accounts.json
  def index
    filter = 'true'
    if params[:topic].to_i != 0
      @topic = Topic.find params[:topic]
      filter += ' and topic_id = :topic' if @topic
    end
    if Account.statuses.include? params[:status]
      filter += ' and status = :status'
    end
    filter += ' and (accounts.name ILIKE :search or accounts.mastodon_handle ILIKE :search' +
      ' or accounts.area_of_focus ILIKE :search or where_to_publish ILIKE :search)' if params[:search].present?
    @pagy, @accounts = pagy(@accounts.where(filter, search: "%#{params[:search]}%",
                                        topic: "#{params[:topic]}", status: Account.statuses[params[:status]]), page_param: :accounts_page)
    delegate_json_to_api
  end

  # GET /account/accounts/:id
  # GET /account/accounts/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/accounts/new
  def new
  end

  # GET /account/accounts/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/accounts
  # POST /account/teams/:team_id/accounts.json
  def create
    respond_to do |format|
      if @account.save
        format.html { redirect_to [:account, @team, :accounts], notice: I18n.t("accounts.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @account] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/accounts/:id
  # PATCH/PUT /account/accounts/:id.json
  def update
    params[:account][:urls].select!(&:present?)
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to [:account, @account], notice: I18n.t("accounts.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @account] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/accounts/:id
  # DELETE /account/accounts/:id.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :accounts], notice: I18n.t("accounts.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_params
    params[:account][:topic_ids] = params.[](:account)&.[](:topic_ids)&.first&.split(',')
    params[:account][:hashtags] = params.[](:account)&.[](:hashtags)&.split(',')
                                   &.map { |hashtag| hashtag.gsub('#', '') }&.join(',')
  end

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
