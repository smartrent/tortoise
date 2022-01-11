defmodule Tortoise311.Connection.Supervisor do
  @moduledoc false

  use Supervisor

  alias Tortoise311.Connection.{Receiver, Controller, Inflight}

  def start_link(opts) do
    client_id = Keyword.fetch!(opts, :client_id)
    Supervisor.start_link(__MODULE__, opts, name: via_name(client_id))
  end

  defp via_name(client_id) do
    Tortoise311.Registry.via_name(__MODULE__, client_id)
  end

  @impl Supervisor
  def init(opts) do
    children = [
      {Inflight, Keyword.take(opts, [:client_id])},
      {Receiver, Keyword.take(opts, [:client_id])},
      {Controller, Keyword.take(opts, [:client_id, :handler])}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
