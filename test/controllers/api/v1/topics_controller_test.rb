require "controllers/api/v1/test"

class Api::V1::TopicsControllerTest < Api::Test
    def setup
      # See `test/controllers/api/test.rb` for common set up for API tests.
      super

      # 🚅 super scaffolding will insert factory setup in place of this line.
      @other_topics = create_list(:topic, 3)

      @another_topic = create(:topic, team: @team)

      # 🚅 super scaffolding will insert file-related logic above this line.
      @topic.save
      @another_topic.save
    end

    # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
    # data we were previously providing to users _will_ break the test suite.
    def assert_proper_object_serialization(topic_data)
      # Fetch the topic in question and prepare to compare it's attributes.
      topic = Topic.find(topic_data["id"])

      assert_equal_or_nil topic_data['definition'], topic.definition
      assert_equal_or_nil topic_data['qcode'], topic.qcode
      assert_equal_or_nil topic_data['wikidata'], topic.wikidata
      assert_equal_or_nil topic_data['uri'], topic.uri
      # 🚅 super scaffolding will insert new fields above this line.

      assert_equal topic_data["team_id"], topic.team_id
    end

    test "index" do
      # Fetch and ensure nothing is seriously broken.
      get "/api/v1/teams/#{@team.id}/topics", params: {access_token: access_token}
      assert_response :success

      # Make sure it's returning our resources.
      topic_ids_returned = response.parsed_body.map { |topic| topic["id"] }
      assert_includes(topic_ids_returned, @topic.id)

      # But not returning other people's resources.
      assert_not_includes(topic_ids_returned, @other_topics[0].id)

      # And that the object structure is correct.
      assert_proper_object_serialization response.parsed_body.first
    end

    test "show" do
      # Fetch and ensure nothing is seriously broken.
      get "/api/v1/topics/#{@topic.id}", params: {access_token: access_token}
      assert_response :success

      # Ensure all the required data is returned properly.
      assert_proper_object_serialization response.parsed_body

      # Also ensure we can't do that same action as another user.
      get "/api/v1/topics/#{@topic.id}", params: {access_token: another_access_token}
      assert_response :not_found
    end

    test "create" do
      # Use the serializer to generate a payload, but strip some attributes out.
      params = {access_token: access_token}
      topic_data = JSON.parse(build(:topic, team: nil).to_api_json.to_json)
      topic_data.except!("id", "team_id", "created_at", "updated_at")
      params[:topic] = topic_data

      post "/api/v1/teams/#{@team.id}/topics", params: params
      assert_response :success

      # # Ensure all the required data is returned properly.
      assert_proper_object_serialization response.parsed_body

      # Also ensure we can't do that same action as another user.
      post "/api/v1/teams/#{@team.id}/topics",
        params: params.merge({access_token: another_access_token})
      assert_response :not_found
    end

    test "update" do
      # Post an attribute update ensure nothing is seriously broken.
      put "/api/v1/topics/#{@topic.id}", params: {
        access_token: access_token,
        topic: {
          definition: 'Alternative String Value',
          qcode: 'Alternative String Value',
          wikidata: 'Alternative String Value',
          uri: 'Alternative String Value',
          # 🚅 super scaffolding will also insert new fields above this line.
        }
      }

      assert_response :success

      # Ensure all the required data is returned properly.
      assert_proper_object_serialization response.parsed_body

      # But we have to manually assert the value was properly updated.
      @topic.reload
      assert_equal @topic.definition, 'Alternative String Value'
      assert_equal @topic.qcode, 'Alternative String Value'
      assert_equal @topic.wikidata, 'Alternative String Value'
      assert_equal @topic.uri, 'Alternative String Value'
      # 🚅 super scaffolding will additionally insert new fields above this line.

      # Also ensure we can't do that same action as another user.
      put "/api/v1/topics/#{@topic.id}", params: {access_token: another_access_token}
      assert_response :not_found
    end

    test "destroy" do
      # Delete and ensure it actually went away.
      assert_difference("Topic.count", -1) do
        delete "/api/v1/topics/#{@topic.id}", params: {access_token: access_token}
        assert_response :success
      end

      # Also ensure we can't do that same action as another user.
      delete "/api/v1/topics/#{@another_topic.id}", params: {access_token: another_access_token}
      assert_response :not_found
    end
end
