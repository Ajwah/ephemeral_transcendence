defmodule ET.Cache.DomainLayer.Server do
  @moduledoc false

  alias ET.Cache.InfrastructureLayer.Repo
  alias ET.Cache.DomainLayer.EvictionPolicies
  def get(key) do
    with {:ok, main_data_point} <- Repo.get(key),
      {:ok, :policy_completed} <- EvictionPolicies.get(main_data_point)
    do
      {:ok, main_data_point[:value]}
    end
  end

  def total_count, do: Repo.total_count()
  def terminate_all, do: Repo.terminate_all()

  def create(key, value) do
    data_point = %{value: value, key: key}
    with {:ok, :policy_completed, annotated_data_point, after_create_related_data} <- EvictionPolicies.create(data_point)
    do
      annotated_data_point
      |> Repo.create
      |> case do
        :ok ->
          EvictionPolicies.after_create(after_create_related_data)
          :ok
        error -> error
      end
    end
  end

  def destroy(data_point) do
    with {:ok, :policy_completed} <- EvictionPolicies.discard(data_point)
    do
      Repo.destroy(data_point[:key])
    end
  end
end
