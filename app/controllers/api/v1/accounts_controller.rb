# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::AccountsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :account, through: :team, through_association: :accounts

    # GET /api/v1/teams/:team_id/accounts
    def index
    end

    # GET /api/v1/accounts/:id
    def show
    end

    # POST /api/v1/teams/:team_id/accounts
    def create
      if @account.save
        render :show, status: :created, location: [:api, :v1, @account]
      else
        render json: @account.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/accounts/:id
    def update
      if @account.update(account_params)
        render :show
      else
        render json: @account.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/accounts/:id
    def destroy
      @account.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def account_params
        strong_params = params.require(:account).permit(
          *permitted_fields,
          :name,
          :mastodon_handle,
          :active,
          :status,
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
          :keywords,
          :hashtags,
          :account_type,
          :address,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          urls: [],
          topic_ids: [],
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::AccountsController
  end
end
