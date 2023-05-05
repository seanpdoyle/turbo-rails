require "test_helper"
require "capybara/minitest"

class Turbo::TestAssertions::CapybaraIntegrationTest < ActiveSupport::TestCase
  include ActionCable::TestHelper, Capybara::Minitest::Assertions

  attr_accessor :page

  test "#assert_turbo_stream_broadcast_on exposes rails-dom-testing assertions in the block" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append target: "message_1"

    assert_turbo_stream_broadcast_on message, action: "append", target: "message_1" do
      assert_selector "p", text: "Hello!", count: 1
      assert_no_selector "p", text: "Goodbye!"
    end
  end
end

class Turbo::TestAssertions::CapybaraActiveJobTestingIntegrationTest < ActiveJob::TestCase
  include ActionCable::TestHelper, Capybara::Minitest::Assertions

  attr_accessor :page

  class AppendJob < ActiveJob::Base
    def perform(message, **options)
      message.broadcast_append(**options)
    end
  end

  test "#assert_turbo_stream_broadcast_on exposes rails-dom-testing assertions in the block" do
    message = Message.new(id: 1, content: "Hello!")

    AppendJob.perform_now(message, target: "message_1")

    assert_turbo_stream_broadcast_on message, action: "append", target: "message_1" do
      assert_selector "p", text: "Hello!", count: 1
      assert_selector "p", text: "Goodbye!", count: 0
    end
  end
end
