defmodule ET.Cache.DomainLayer.EvictionPolicies.None do
  @moduledoc false

  def get(_), do: {:ok, :policy_completed}
  def create(data_point), do: {:ok, :policy_completed, data_point, :ok}
  def after_create(_), do: :ok
  def discard(_), do: {:ok, :policy_completed}
end
