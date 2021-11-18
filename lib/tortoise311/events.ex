defmodule Tortoise311.Events do
  @moduledoc """
  A PubSub exposing various system events from a Tortoise311
  connection. This allows the user to integrate with custom metrics
  and logging solutions.

  Please read the documentation for `Tortoise311.Events.register/2` for
  information on how to subscribe to events, and
  `Tortoise311.Events.unregister/2` for how to unsubscribe.
  """

  @types [:connection, :status, :ping_response]

  @doc """
  Subscribe to messages on the client with the client id `client_id`
  of the type `type`.

  When a message of the subscribed type is dispatched it will end up
  in the mailbox of the process that placed the subscription. The
  received message will have the format:

      {{Tortoise311, client_id}, type, value}

  Making it possible to pattern match on multiple message types on
  multiple clients. The value depends on the message type.

  Possible message types are:

    - `:status` dispatched when the connection of a client changes
      status. The value will be `:up` when the client goes online, and
      `:down` when it goes offline.

    - `:ping_response` dispatched when the connection receive a
      response from a keep alive message. The value is the round trip
      time in milliseconds, and can be used to track the latency over
      time.

  Other message types exist, but unless they are mentioned in the
  possible message types above they should be considered for internal
  use only.

  It is possible to listen on all events for a given type by
  specifying `:_` as the `client_id`.
  """
  @spec register(Tortoise311.client_id(), atom()) :: {:ok, pid()} | no_return()
  def register(client_id, type) when type in @types do
    {:ok, _pid} = Registry.register(__MODULE__, type, client_id)
  end

  @doc """
  Unsubscribe from messages of `type` from `client_id`. This is the
  reverse of `Tortoise311.Events.register/2`.
  """
  @spec unregister(Tortoise311.client_id(), atom()) :: :ok | no_return()
  def unregister(client_id, type) when type in @types do
    :ok = Registry.unregister_match(__MODULE__, type, client_id)
  end

  @doc false
  @spec dispatch(Tortoise311.client_id(), type :: atom(), value :: term()) :: :ok
  def dispatch(client_id, type, value) when type in @types do
    :ok =
      Registry.dispatch(__MODULE__, type, fn subscribers ->
        for {pid, filter} <- subscribers,
            filter == client_id or filter == :_ do
          Kernel.send(pid, {{Tortoise311, client_id}, type, value})
        end
      end)
  end
end
