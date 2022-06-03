defmodule Tortoise311.Package.Unsubscribe do
  @moduledoc false

  alias Tortoise311.Package

  @opcode 10

  @type topic :: binary()

  @opaque t :: %__MODULE__{
            __META__: Package.Meta.t(),
            identifier: Tortoise311.package_identifier(),
            topics: [topic]
          }

  defstruct __META__: %Package.Meta{opcode: @opcode, flags: 2},
            topics: [],
            identifier: nil

  @spec decode(binary()) :: t | {:error, :invalid_unsubscription_payload}
  def decode(<<@opcode::4, 0b0010::4, payload::binary>>) do
    with payload <- drop_length(payload),
         <<identifier::big-integer-size(16), topics::binary>> <- payload,
         topic_list <- decode_topics(topics) do
      %__MODULE__{identifier: identifier, topics: topic_list}
    else
      _invalid_payload ->
        {:error, :invalid_unsubscription_payload}
    end
  end

  defp drop_length(payload) do
    case payload do
      <<0::1, _::7, r::binary>> -> r
      <<1::1, _::7, 0::1, _::7, r::binary>> -> r
      <<1::1, _::7, 1::1, _::7, 0::1, _::7, r::binary>> -> r
      <<1::1, _::7, 1::1, _::7, 1::1, _::7, 0::1, _::7, r::binary>> -> r
    end
  end

  defp decode_topics(<<>>), do: []

  defp decode_topics(<<length::big-integer-size(16), rest::binary>>) do
    <<topic::binary-size(length), rest::binary>> = rest
    [topic] ++ decode_topics(rest)
  end

  # Protocols ----------------------------------------------------------
  defimpl Tortoise311.Encodable do
    def encode(
          %Package.Unsubscribe{
            identifier: identifier,
            # a valid unsubscribe package has at least one topic filter
            topics: [_topic_filter | _]
          } = t
        )
        when identifier in 0x0001..0xFFFF do
      [
        Package.Meta.encode(t.__META__),
        Package.variable_length_encode([
          <<identifier::big-integer-size(16)>>,
          Enum.map(t.topics, &Package.length_encode/1)
        ])
      ]
    end
  end
end
