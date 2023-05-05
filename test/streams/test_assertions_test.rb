require "test_helper"

class Turbo::TestAssertions::AssertTurboStreamBroadcastOnTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "#assert_turbo_stream_broadcast_on for append broadcast to a signed stream derived from a Model" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append target: "message_1"

    assert_turbo_stream_broadcast_on message, action: "append", target: "message_1" do |html|
      assert_includes html.to_html, message.content
      assert_not_includes html.to_html, "Goodbye!"
    end
  end

  test "#assert_turbo_stream_broadcast_on for append broadcast to a signed stream derived from an Array" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to [message, :special_channel], target: "message_1"

    assert_turbo_stream_broadcast_on [message, :special_channel], action: "append", target: "message_1" do |html|
      assert_includes html.to_html, message.content
      assert_not_includes html.to_html, "Goodbye!"
    end
  end

  test "#assert_turbo_stream_broadcast_on for append broadcast to stream" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to "stream", target: "message_1"

    assert_turbo_stream_broadcast_on "stream", action: "append", target: "message_1" do |html|
      assert_includes html.to_html, message.content
      assert_not_includes html.to_html, "Goodbye!"
    end
  end

  test "#assert_turbo_stream_broadcast_on for action without a <template>" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_remove_to "stream", target: "message_1"

    assert_turbo_stream_broadcast_on "stream", action: "remove", target: "message_1"
  end

  test "#assert_turbo_stream_broadcast_on call with block for action without a <template> flunks" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_remove_to "stream", target: "message_1"

    assert_raises MiniTest::Assertion do
      assert_turbo_stream_broadcast_on "stream", action: "remove", target: "message_1" do
        fail "this block should never be invoked"
      end
    end
  end

  test "#assert_turbo_stream_broadcast_on flunks with no broadcasts" do
    failure = assert_raises MiniTest::Assertion do
      assert_turbo_stream_broadcast_on "stream"
    end
    assert_includes failure.message, %(no broadcasts on stream "stream")
  end

  test "#assert_turbo_stream_broadcast_on flunks with no matching [action]" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to "stream", target: "message_1"

    failure = assert_raises MiniTest::Assertion do
      assert_turbo_stream_broadcast_on "stream", action: "remove", target: "message_1"
    end
    assert_includes failure.message, %(turbo-stream[action="remove"][target="message_1"])
  end

  test "#assert_turbo_stream_broadcast_on flunks with no matching [target]" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to "stream", target: "message_1"

    failure = assert_raises MiniTest::Assertion do
      assert_turbo_stream_broadcast_on "stream", action: "append", target: "missing_element"
    end
    assert_includes failure.message, %(turbo-stream[action="append"][target="missing_element"])
  end

  test "#assert_turbo_stream_broadcast_on flunks with no matching [targets]" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to "stream", target: "message_1"

    failure = assert_raises MiniTest::Assertion do
      assert_turbo_stream_broadcast_on "stream", action: "append", targets: ".missing_elements"
    end
    assert_includes failure.message, %(turbo-stream[action="append"][targets=".missing_elements"])
  end
end

class Turbo::TestAssertions::AssertNoTurboStreamBroadcastOnTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "#assert_no_turbo_stream_broadcast_on with any broadcasts" do
    assert_no_turbo_stream_broadcast_on "stream"
  end

  test "#assert_no_turbo_stream_broadcast_on ignores other channels" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to "stream", target: "message_1"

    assert_no_turbo_stream_broadcast_on "another_stream"
  end

  test "#assert_no_turbo_stream_broadcast_on passes without matching attributes" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to "stream"

    assert_no_turbo_stream_broadcast_on "stream", action: "remove"
  end

  test "#assert_no_turbo_stream_broadcast_on fails with matching attributes" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to "stream"

    assert_raises MiniTest::Assertion do
      assert_no_turbo_stream_broadcast_on "stream", action: "append"
    end
  end

  test "#assert_no_turbo_stream_broadcast_on fails with partially matching attributes" do
    message = Message.new(id: 1, content: "Hello!")

    message.broadcast_append_to "stream", target: "message_1"

    assert_no_turbo_stream_broadcast_on "stream", action: "append", target: "missing_element"
  end
end
