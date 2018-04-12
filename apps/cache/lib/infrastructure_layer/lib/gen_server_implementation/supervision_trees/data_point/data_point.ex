defmodule ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.DataPoint do
  use GenServer
  def start_link(data_point_info) do
    GenServer.start_link(__MODULE__, data_point_info, name: data_point_info[:key])
  end

  def init(state = %{prev: _, next: _, value: _}) do
    {:ok, state}
  end

  def get_pid(key) do
    key
    |> GenServer.whereis
    |> case do
      nil -> {:error, :get_pid, :not_found}
      pid -> {:ok, pid}
    end
  end

  def retrieve_state(key) do
    key
    |> get_pid
    |> case do
      {:error, :get_pid, :not_found} -> {:error, :retrieve_state, :not_found}
      {:ok, pid} -> {:ok, GenServer.call(pid, :retrieve_state)}
    end
  end

  def update_state(new_state = %{prev: _, next: _, value: _, key: key}) do
    key
    |> GenServer.whereis
    |> case do
      nil -> {:error, :update_state, :not_found}
      pid -> pid
        |> GenServer.call({:update_state, new_state})
    end
  end

  def handle_call(:retrieve_state, _, state) do
    {:reply, state, state}
  end

  def handle_call({:update_state, new_state}, _, _) do
    {:reply, :ok, new_state}
  end
end
