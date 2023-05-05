module Turbo
  module TestAssertions
    extend ActiveSupport::Concern

    included do
      include Turbo::Streams::StreamName

      # FIXME: Should happen in Rails at a different level
      delegate :dom_id, :dom_class, to: ActionView::RecordIdentifier
    end

    def assert_turbo_stream(action:, target: nil, targets: nil, status: :ok, &block)
      assert_response status
      assert_equal Mime[:turbo_stream], response.media_type
      selector =  %(turbo-stream[action="#{action}"])
      selector << %([target="#{target.respond_to?(:to_key) ? dom_id(target) : target}"]) if target
      selector << %([targets="#{targets}"]) if targets
      assert_select selector, count: 1, &block
    end

    def assert_no_turbo_stream(action:, target: nil, targets: nil)
      assert_equal Mime[:turbo_stream], response.media_type
      selector =  %(turbo-stream[action="#{action}"])
      selector << %([target="#{target.respond_to?(:to_key) ? dom_id(target) : target}"]) if target
      selector << %([targets="#{targets}"]) if targets
      assert_select selector, count: 0
    end

    def assert_turbo_stream_broadcast_on(stream_name, **attributes, &block)
      broadcasts_on_stream = broadcasts(stream_name_from(stream_name))

      if broadcasts_on_stream.empty?
        flunk "no broadcasts on stream #{stream_name.inspect}"
      end

      turbo_streams = broadcasts_on_stream.map do |message|
        html = ActiveSupport::JSON.decode(message)
        fragment = Nokogiri::HTML(html)

        fragment.at("turbo-stream")
      end

      broadcast_turbo_stream = turbo_streams.detect { |turbo_stream| attributes.all? { |name, value| turbo_stream[name] == value } }

      if broadcast_turbo_stream.nil?
        selector = attributes.map { |name, value| %([#{name}="#{value}"]) }

        flunk "Broadcasted message missing turbo-stream#{selector.join}"
      else
        template = broadcast_turbo_stream.at("template")

        if template.nil? && block
          flunk "Broadcasted turbo-stream has no <template> element"
        else
          template.yield_self(&block)
        end
      end

      pass
    end

    def assert_no_turbo_stream_broadcast_on(stream_name, **attributes, &block)
      turbo_streams = broadcasts(stream_name).map do |message|
        html = ActiveSupport::JSON.decode(message)
        fragment = Nokogiri::HTML(html)

        fragment.at("turbo-stream")
      end

      broadcast_turbo_streams = turbo_streams.select { |turbo_stream| attributes.all? { |name, value| turbo_stream[name] == value } }

      if broadcast_turbo_streams.any?
        selector = attributes.map { |name, value| %([#{name}="#{value}"]) }

        flunk "Broadcasted message with turbo-stream#{selector.join}, but expected not to"
      end

      pass
    end
  end
end
