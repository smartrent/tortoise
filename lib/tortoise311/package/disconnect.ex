defmodule Tortoise311.Package.Disconnect do
  @moduledoc false

  @opcode 14

  alias Tortoise311.Package

  @opaque t :: %__MODULE__{
            __META__: Package.Meta.t()
          }
  defstruct __META__: %Package.Meta{opcode: @opcode, flags: 0}

  @spec decode(<<_::16>>) :: t
  def decode(<<@opcode::4, 0::4, 0>>), do: %__MODULE__{}

  # Protocols ----------------------------------------------------------
  defimpl Tortoise311.Encodable do
    def encode(%Package.Disconnect{} = t) do
      [Package.Meta.encode(t.__META__), 0]
    end
  end
end
