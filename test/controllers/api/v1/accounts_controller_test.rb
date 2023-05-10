require "controllers/api/v1/test"

class Api::V1::AccountsControllerTest < Api::Test
    def setup
      # See `test/controllers/api/test.rb` for common set up for API tests.
      super

      @account = build(:account, team: @team)
      @other_accounts = create_list(:account, 3)

      @another_account = create(:account, team: @team)

      # 🚅 super scaffolding will insert file-related logic above this line.
      @account.save
      @another_account.save
    end

    # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
    # data we were previously providing to users _will_ break the test suite.
    def assert_proper_object_serialization(account_data)
      # Fetch the account in question and prepare to compare it's attributes.
      account = Account.find(account_data["id"])

      assert_equal_or_nil account_data['name'], account.name
      assert_equal_or_nil account_data['mastodon_handle'], account.mastodon_handle
      assert_equal_or_nil account_data['twitter_handle'], account.twitter_handle
      assert_equal_or_nil account_data['area_of_focus'], account.area_of_focus
      assert_equal_or_nil account_data['where_to_publish'], account.where_to_publish
      assert_equal_or_nil account_data['description'], account.description
      assert_equal_or_nil account_data['topic_id'], account.topic_id
      assert_equal_or_nil accounts_data['active'], accounts.active
      assert_equal_or_nil accounts_data['status'], accounts.status
      assert_equal_or_nil account_data['email'], account.email
      assert_equal_or_nil account_data['first_name'], account.first_name
      assert_equal_or_nil account_data['last_name'], account.last_name
      assert_equal_or_nil account_data['country'], account.country
      assert_equal_or_nil account_data['region'], account.region
      assert_equal_or_nil account_data['phone_number'], account.phone_number
      assert_equal_or_nil account_data['job_title'], account.job_title
      assert_equal_or_nil account_data['organisation'], account.organisation
      assert_equal_or_nil account_data['organisation_type'], account.organisation_type
      assert_equal_or_nil account_data['website_url'], account.website_url
      assert_equal_or_nil account_data['blog_url'], account.blog_url
      assert_equal_or_nil account_data['show_email'], account.show_email
      assert_equal_or_nil account_data['show_phone'], account.show_phone
      assert_equal_or_nil account_data['mastodon_url'], account.mastodon_url
      assert_equal_or_nil account_data['show_location'], account.show_location
      assert_equal_or_nil account_data['keywords'], account.keywords
      assert_equal_or_nil account_data['hashtags'], account.hashtags
      assert_equal_or_nil account_data['account_type'], account.account_type
      assert_equal_or_nil account_data['address'], account.address
      # 🚅 super scaffolding will insert new fields above this line.

      assert_equal account_data["team_id"], account.team_id
    end

    test "index" do
      # Fetch and ensure nothing is seriously broken.
      get "/api/v1/teams/#{@team.id}/accounts", params: {access_token: access_token}
      assert_response :success

      # Make sure it's returning our resources.
      account_ids_returned = response.parsed_body.map { |account| account["id"] }
      assert_includes(account_ids_returned, @account.id)

      # But not returning other people's resources.
      assert_not_includes(account_ids_returned, @other_accounts[0].id)

      # And that the object structure is correct.
      assert_proper_object_serialization response.parsed_body.first
    end

    test "show" do
      # Fetch and ensure nothing is seriously broken.
      get "/api/v1/accounts/#{@account.id}", params: {access_token: access_token}
      assert_response :success

      # Ensure all the required data is returned properly.
      assert_proper_object_serialization response.parsed_body

      # Also ensure we can't do that same action as another user.
      get "/api/v1/accounts/#{@account.id}", params: {access_token: another_access_token}
      assert_response :not_found
    end

    test "create" do
      # Use the serializer to generate a payload, but strip some attributes out.
      params = {access_token: access_token}
      account_data = JSON.parse(build(:account, team: nil).to_api_json.to_json)
      account_data.except!("id", "team_id", "created_at", "updated_at")
      params[:account] = account_data

      post "/api/v1/teams/#{@team.id}/accounts", params: params
      assert_response :success

      # # Ensure all the required data is returned properly.
      assert_proper_object_serialization response.parsed_body

      # Also ensure we can't do that same action as another user.
      post "/api/v1/teams/#{@team.id}/accounts",
        params: params.merge({access_token: another_access_token})
      assert_response :not_found
    end

    test "update" do
      # Post an attribute update ensure nothing is seriously broken.
      put "/api/v1/accounts/#{@account.id}", params: {
        access_token: access_token,
        account: {
          name: 'Alternative String Value',
          mastodon_handle: 'Alternative String Value',
          twitter_handle: 'Alternative String Value',
          area_of_focus: 'Alternative String Value',
          where_to_publish: 'Alternative String Value',
          description: 'Alternative String Value',
          email: 'another.email@test.com',
          first_name: 'Alternative String Value',
          last_name: 'Alternative String Value',
          country: 'Alternative String Value',
          region: 'Alternative String Value',
          phone_number: '+19053871234',
          job_title: 'Alternative String Value',
          organisation: 'Alternative String Value',
          organisation_type: 'Alternative String Value',
          website_url: 'Alternative String Value',
          blog_url: 'Alternative String Value',
          mastodon_url: 'Alternative String Value',
          keywords: 'Alternative String Value',
          hashtags: 'Alternative String Value',
          address: 'Alternative String Value',
          # 🚅 super scaffolding will also insert new fields above this line.
        }
      }

      assert_response :success

      # Ensure all the required data is returned properly.
      assert_proper_object_serialization response.parsed_body

      # But we have to manually assert the value was properly updated.
      @account.reload
      assert_equal @account.name, 'Alternative String Value'
      assert_equal @account.mastodon_handle, 'Alternative String Value'
      assert_equal @account.twitter_handle, 'Alternative String Value'
      assert_equal @account.area_of_focus, 'Alternative String Value'
      assert_equal @account.where_to_publish, 'Alternative String Value'
      assert_equal @account.description, 'Alternative String Value'
      assert_equal @account.email, 'another.email@test.com'
      assert_equal @account.first_name, 'Alternative String Value'
      assert_equal @account.last_name, 'Alternative String Value'
      assert_equal @account.country, 'Alternative String Value'
      assert_equal @account.region, 'Alternative String Value'
      assert_equal @account.phone_number, '+19053871234'
      assert_equal @account.job_title, 'Alternative String Value'
      assert_equal @account.organisation, 'Alternative String Value'
      assert_equal @account.organisation_type, 'Alternative String Value'
      assert_equal @account.website_url, 'Alternative String Value'
      assert_equal @account.blog_url, 'Alternative String Value'
      assert_equal @account.mastodon_url, 'Alternative String Value'
      assert_equal @account.keywords, 'Alternative String Value'
      assert_equal @account.hashtags, 'Alternative String Value'
      assert_equal @account.address, 'Alternative String Value'
      # 🚅 super scaffolding will additionally insert new fields above this line.

      # Also ensure we can't do that same action as another user.
      put "/api/v1/accounts/#{@account.id}", params: {access_token: another_access_token}
      assert_response :not_found
    end

    test "destroy" do
      # Delete and ensure it actually went away.
      assert_difference("Account.count", -1) do
        delete "/api/v1/accounts/#{@account.id}", params: {access_token: access_token}
        assert_response :success
      end

      # Also ensure we can't do that same action as another user.
      delete "/api/v1/accounts/#{@another_account.id}", params: {access_token: another_access_token}
      assert_response :not_found
    end
end
