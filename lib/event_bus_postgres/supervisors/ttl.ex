defmodule EventBus.Postgres.Supervisor.TTL do
  @moduledoc false

  use Supervisor

  alias EventBus.Postgres.Worker.TTL, as: TTLWorker

  @doc false
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc false
  @spec init(list()) :: no_return()
  def init(_opts) do
    children = [
      TTLWorker
    ]

    Supervisor.init(children, strategy: :one_for_one, name: __MODULE__)
  end
end
