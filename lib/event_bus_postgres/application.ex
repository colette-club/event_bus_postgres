defmodule EventBus.Postgres.Application do
  @moduledoc false

  use Application

  alias EventBus.Postgres
  alias EventBus.Postgres.{Bucket, Config, EventMapper, Queue, Repo}
  alias EventBus.Postgres.Supervisor.TTL, as: TTLSupervisor

  def start(_type, args) do
    link =
      Supervisor.start_link(
        children(args),
        strategy: :one_for_one,
        name: EventBus.Postgres.Supervisor
      )

    if Config.enabled?() do
      EventBus.subscribe({Postgres, Config.topics()})
    end

    link
  end

  defp children(_args) do
    [
      Repo,
      Queue,
      EventMapper
    ] ++ bucket_workers() ++ auto_deletion_workers()
  end

  defp auto_deletion_workers do
    if Config.auto_delete_with_ttl?() do
      [TTLSupervisor]
    else
      []
    end
  end

  defp bucket_workers do
    Enum.map(1..Config.pool_size(), fn _ ->
      Bucket
    end)
  end
end
