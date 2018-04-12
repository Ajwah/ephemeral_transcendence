defmodule ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.StaticTree.TopLevelSupervisor do
  use Supervisor

  @opts [strategy: :one_for_one] ++ Application.get_env(:cache, :otp)

  @dummy_point_conf %{
    first: %{key: DummyDataPoint.First, value: self(), next: DummyDataPoint.Last, prev: nil},
    last: %{key: DummyDataPoint.Last, value: self(), next: nil, prev: DummyDataPoint.First},
  }

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  alias ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.DataPoint

  def init(_) do
    children = [
      worker(DataPoint, [@dummy_point_conf[:first]], [id: 1]),
      worker(DataPoint, [@dummy_point_conf[:last]], [id: 2]),
    ]

    supervise(children, @opts)
  end

  def reset_children do
    DataPoint.update_state(@dummy_point_conf[:first])
    DataPoint.update_state(@dummy_point_conf[:last])
  end
end
