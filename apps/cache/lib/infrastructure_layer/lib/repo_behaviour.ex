defmodule ET.Cache.InfrastructureLayer.Repo.Behaviour do
  @moduledoc false
  @callback create(any) :: {:error, atom, atom} | :ok
  @callback destroy(any) :: :ok
  @callback get(atom) :: {:ok, any} | {:error, :retrieve_state, :not_found}
  @callback update(any) :: :ok | {:error, :update_state, :not_found}
  @callback total_count() :: pos_integer
  @callback terminate_all() :: :ok
end
