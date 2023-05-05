require "test_helper"

module Turbo::TestAssertions::RailsDomTesting
end

class Turbo::TestAssertions::RailsDomTesting::ActiveJobTestingIntegrationTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  class AppendJob < ActiveJob::Base
    def perform(message, **options)
      message.broadcast_append(**options)
    end
  end

  test "#assert_turbo_stream_broadcast_on exposes rails-dom-testing assertions in the block" do
    message = Message.new(id: 1, content: "Hello!")

    AppendJob.perform_now(message, target: "message_1")

    assert_turbo_stream_broadcast_on message, action: "append", target: "message_1" do
      assert_select "p", text: "Hello!", count: 1
      assert_select "p", text: "Goodbye!", count: 0
    end
  end
end

class Turbo::TestAssertions::RailsDomTesting::ActionDispatchIntegrationTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  test "#assert_turbo_stream_broadcast_on exposes rails-dom-testing assertions in the block" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append target: "message_1"

    assert_turbo_stream_broadcast_on message, action: "append", target: "message_1" do
      assert_select "p", text: "Hello!", count: 1
      assert_select "p", text: "Goodbye!", count: 0
    end
  end
end
