defmodule Tortoise311.Package.Unsuback do
  @moduledoc false

  @opcode 11

  alias Tortoise311.Package

  @opaque t :: %__MODULE__{
            __META__: Package.Meta.t(),
            identifier: Tortoise311.package_identifier()
          }
  @enforce_keys [:identifier]
  defstruct __META__: %Package.Meta{opcode: @opcode, flags: 0b0000},
            identifier: nil

  @spec decode(<<_::32>>) :: t
  def decode(<<@opcode::4, 0::4, 2, identifier::big-integer-size(16)>>)
      when identifier in 0x0001..0xFFFF do
    %__MODULE__{identifier: identifier}
  end

  # Protocols ----------------------------------------------------------
  defimpl Tortoise311.Encodable do
    def encode(%Package.Unsuback{identifier: identifier} = t)
        when identifier in 0x0001..0xFFFF do
      [Package.Meta.encode(t.__META__), <<2, identifier::big-integer-size(16)>>]
    end
  end
end
