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

  test "#get by a non-existent key fails gracefully." do
    {state, action, result} = Server.get(:non_existent)

    assert {state, action, result} == {:error, :retrieve_state, :not_found}
  end

  @eviction_threshold Application.get_env(:cache, :eviction_policy)[:threshold]
  @tag big_one: true
  @tag timeout: 300_000
  @mix_command """
    iex --erl "+P 5000000" -S mix test test/server_test.exs --only big_one:true
  """
  test "server is able to store a large quantity of items" do
    IO.inspect("Kindly take note that this test needs to run wih erlang options to increase amount processes from a mere thousand to a large number: #{@mix_command}")
    max = 10_000 # up to a million
    1..max
    |> Enum.map(fn i ->
      if rem(i, 10_000) == 0 do
        IO.inspect(i, label: :counter_of_processes)
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
