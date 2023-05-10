# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::TopicsController < Api::V1::ApplicationController
    account_load_and_authorize_resource :topic, through: :team, through_association: :topics

    # GET /api/v1/teams/:team_id/topics
    def index
    end

    # GET /api/v1/topics/:id
    def show
    end

    # POST /api/v1/teams/:team_id/topics
    def create
      if @topic.save
        render :show, status: :created, location: [:api, :v1, @topic]
      else
        render json: @topic.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/topics/:id
    def update
      if @topic.update(topic_params)
        render :show
      else
        render json: @topic.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/topics/:id
    def destroy
      @topic.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def topic_params
        strong_params = params.require(:topic).permit(
          *permitted_fields,
          :name,
          :definition,
          :qcode,
          :wikidata,
          :parent_id,
          :uri,
          # 🚅 super scaffolding will insert new fields above this line.
          *permitted_arrays,
          # 🚅 super scaffolding will insert new arrays above this line.
        )

        process_params(strong_params)

        strong_params
      end
    end

    include StrongParameters
  end
else
  class Api::V1::TopicsController
  end
end
