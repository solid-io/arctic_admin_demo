# frozen_string_literal: true

require "test_helper"

class WebpushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get webpush_subscriptions_index_url
    assert_response :success
  end

  test "should get create" do
    get webpush_subscriptions_create_url
    assert_response :success
  end
end
