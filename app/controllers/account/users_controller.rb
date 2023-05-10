class Account::UsersController < Account::ApplicationController
  include Account::Users::ControllerBase


  def index
    filter = 'true'
    filter += ' and (users.first_name ILIKE :search or users.last_name ILIKE :search' +
              ' or users.email ILIKE :search)' if params[:search].present?
    @pagy, @users = pagy(User.where(filter, search: "%#{params[:search]}%"), page_param: :users_page)
    delegate_json_to_api
  end

  def new
    redirect_to edit_account_user_path(current_user) unless current_user.admin?(current_team)
    @user = User.new
  end

  def edit

  end

  def destroy
    @user.destroy unless @user == current_user
    redirect_to action: :index
  end

  def create
    respond_to do |format|
      role = Role.admin if params[:role].present?
      if @user.save
        current_team.memberships.create(user: @user, roles: role ? [role] : [])
        format.html { redirect_to [:account, @team, :users], notice: I18n.t("users.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @user] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def permitted_fields
    []
  end

  def permitted_arrays
    {}
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
    strong_params
  end
end
