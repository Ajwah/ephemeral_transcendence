defmodule ServerTest do
  use ExUnit.Case, async: false
  alias ET.Cache.DomainLayer.Server
  doctest Server

  alias ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.StaticTree
  alias ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.DynamicTree

  setup do
    cleanup()
  end

  def cleanup do
    Supervisor.stop(DynamicTree.TopLevelSupervisor)
    wait_supervisor(DynamicTree.TopLevelSupervisor)
    StaticTree.TopLevelSupervisor.reset_children()
  end

  def wait_supervisor(supervisor) do
    supervisor
    |> GenServer.whereis
    |> case do
      nil ->
        wait_supervisor(supervisor)
      _ -> :ok
    end
  end

  test "Adding one element should be a successfull contrast between nothing previously and something now." do
    nothing = Server.total_count
    result = Server.create(:a, "b")
    one = Server.total_count

    assert nothing == 0
    assert result == :ok
    assert one == 1
  end

  test "Adding a value by key allows to retrieve that same value by the same key" do
    the_key = :b
    the_value = "b"

    Server.create(the_key, the_value)
    {:ok, retrieved_value} = Server.get(the_key)
    assert retrieved_value == the_value
  end

  @tag combine: true
  @tag timeout: 300_000
  test "#get by a non-existent key fails gracefully." do
    {state, action, result} = Server.get(:non_existent)

    assert {state, action, result} == {:error, :retrieve_state, :not_found}
  end

  @eviction_threshold Application.get_env(:cache, :eviction_policy)[:threshold]
  @tag combine: true
  @tag big_one: true
  @tag timeout: 300_000
  test "server is able to store a large qauntity of items" do
    max = 1_000_000
    1..max
    |> Enum.map(fn i ->
      if rem(i, 10_000) == 0 do
        IO.inspect(i, label: :counter)
      end
      key = "a_#{i}"
        |> String.to_atom

      key
      |> Server.create("a_#{i}")

      {key, i}
    end)

    total = Server.total_count
    if @eviction_threshold < max do
      assert total == max
    else
      assert total == @eviction_threshold
    end
  end
end
