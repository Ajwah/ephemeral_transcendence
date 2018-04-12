defmodule ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.DynamicTree.TopLevelSupervisor do
  use Supervisor

  @opts [strategy: :simple_one_for_one] ++ Application.get_env(:cache, :otp)

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  alias ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.DataPoint
  def init(_) do
    children = [
      worker(DataPoint, [], restart: :transient)
    ]

    supervise(children, @opts)
  end

  def add_child(data_point) do
    __MODULE__
    |> Supervisor.start_child([data_point])
    |> case do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, :anomaly, reason}
    end
  end

  def remove_child(pid) do
    Supervisor.terminate_child(__MODULE__, pid)
  end

  def count_children do
    %{active: active} = Supervisor.count_children(__MODULE__)
    active
  end

  def terminate_all do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.each(fn {_, pid, _, _} ->
      remove_child(pid)
    end)
    :ok
  end
end
