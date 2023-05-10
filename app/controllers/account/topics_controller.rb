class Account::TopicsController < Account::ApplicationController
  account_load_and_authorize_resource :topic, through: :team, through_association: :topics

  # GET /account/teams/:team_id/topics
  # GET /account/teams/:team_id/topics.json
  def index
    delegate_json_to_api
  end

  # GET /account/topics/:id
  # GET /account/topics/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/topics/new
  def new
  end

  # GET /account/topics/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/topics
  # POST /account/teams/:team_id/topics.json
  def create
    respond_to do |format|
      if @topic.save
        format.html { redirect_to [:account, @team, :topics], notice: I18n.t("topics.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @topic] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/topics/:id
  # PATCH/PUT /account/topics/:id.json
  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to [:account, @topic], notice: I18n.t("topics.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @topic] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/topics/:id
  # DELETE /account/topics/:id.json
  def destroy
    @topic.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :topics], notice: I18n.t("topics.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
