defmodule ET.Cache.DomainLayer.EvictionPolicies.LRU do
  @moduledoc false
  alias ET.Cache.InfrastructureLayer.Repo

  def get(main_data_point = %{key: key}) do
    with {:ok, first_data_point} <- Repo.get(DummyDataPoint.First),
      {:ok, second_data_point} <- Repo.get(first_data_point[:next]),

      {:ok, before_main_data_point} <- Repo.get(main_data_point[:prev]),
      {:ok, after_main_data_point} <- Repo.get(main_data_point[:next]),

      :ok <- Repo.update(annotate_data_point(first_data_point[:prev], key, first_data_point)),
      :ok <- Repo.update(annotate_data_point(key, second_data_point[:next], second_data_point)),
      :ok <- Repo.update(annotate_data_point(DummyDataPoint.First, second_data_point[:key], main_data_point)),
      :ok <- Repo.update(annotate_data_point(before_main_data_point[:prev], after_main_data_point[:key], before_main_data_point)),
      :ok <- Repo.update(annotate_data_point(before_main_data_point[:key], after_main_data_point[:next], after_main_data_point))
    do
      {:ok, :policy_completed}
    end
  end

  @eviction_threshold Application.get_env(:cache, :eviction_policy)[:threshold] |> IO.inspect(label: :count)
  alias ET.Cache.DomainLayer.Server
  def create(data_point) do
    if Server.total_count() < @eviction_threshold do
      data_point
      |> prepend
    else
      data_point
      |> Server.destroy

      prepend(data_point)
    end
  end

  def after_create({key, first_data_point, second_data_point}) do
    Repo.update(annotate_data_point(first_data_point[:prev], key, first_data_point))
    Repo.update(annotate_data_point(key, second_data_point[:next], second_data_point))
  end

  def discard(%{value: _, key: key}) do
    with {:ok, last_data_point = %{prev: prev}} <- Repo.get(DummyDataPoint.Last),
      {:ok, second_last_data_point} <- Repo.get(prev),
      {:ok, third_last_data_point} <- Repo.get(second_last_data_point[:prev]),
      {:error, :retrieve_state, :not_found} <- Repo.get(key),

      :ok <- Repo.update(annotate_data_point(second_last_data_point[:prev], last_data_point[:next], last_data_point)),
      :ok <- Repo.update(annotate_data_point(third_last_data_point[:prev], DummyDataPoint.Last, third_last_data_point))
    do
      {:ok, :policy_completed}
    else
      {:ok, _} -> {:error, :provided_key_already_taken}
      error -> error
    end
  end

  defp prepend(data_point = %{value: _, key: key}) do
    with {:ok, first_data_point = %{next: next}} <- Repo.get(DummyDataPoint.First),
      {:ok, second_data_point} <- Repo.get(next),
      {:error, :retrieve_state, :not_found} <- Repo.get(key)
    do
      annotated_data_point = annotate_data_point(second_data_point[:prev], first_data_point[:next], data_point)
      {:ok, :policy_completed, annotated_data_point, {key, first_data_point, second_data_point}}
    else
      {:ok, _} -> {:error, :insertion, :provided_key_already_taken}
      error -> error
    end
  end

  defp annotate_data_point(prev, next, data_point) do
    data_point
    |> Map.merge(%{next: next, prev: prev})
  end
end
