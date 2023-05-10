require "test_helper"

class Public::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get check" do
    get public_accounts_check_url
    assert_response :success
  end

  test "should get create" do
    get public_accounts_create_url
    assert_response :success
  end

  test "should get edit" do
    get public_accounts_edit_url
    assert_response :success
  end
end
