defmodule ET.Cache.Application do
  @moduledoc false
  use Application

  @opts [ strategy: :one_for_one,
    name: ET.Cache.InfrastructureLevel.TopLevelSupervisor
  ] ++ Application.get_env(:cache, :otp)

  alias ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.DynamicTree
  alias ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.StaticTree

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(DynamicTree.TopLevelSupervisor, [[]]),
      supervisor(StaticTree.TopLevelSupervisor, [[]]),
    ]

    Supervisor.start_link(children, @opts)
  end
end
