defmodule ET.Cache.DomainLayer.EvictionPolicies do
  @moduledoc false

  def get(data_point) do
    apply(obtain_eviction_policy_mapping(), :get, [data_point])
  end

  def create(data_point) do
    apply(obtain_eviction_policy_mapping(), :create, [data_point])
  end

  def after_create(related_data) do
    apply(obtain_eviction_policy_mapping(), :after_create, [related_data])
  end

  def discard(data_point) do
    apply(obtain_eviction_policy_mapping(), :discard, [data_point])
  end

  @eviction_policy Application.get_env(:cache, :eviction_policy)[:type]
  @anomaly_msg "Impossible anomaly | No other policies besides lru are available, yet provided:"
  defp obtain_eviction_policy_mapping do
    @eviction_policy
    |> case do
      :lru -> __MODULE__.LRU
      :none -> __MODULE__.None
      other -> raise "#{@anomaly_msg} #{inspect(other)}"
    end
  end
end
