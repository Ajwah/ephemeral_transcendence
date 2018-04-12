defmodule ET.Cache.InfrastructureLayer.Repo.GenServerImplementation do
  @moduledoc false
  defmacro __using__(_) do
    quote location: :keep do
      alias ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.DataPoint
      alias ET.Cache.InfrastructureLayer.Repo.GenserverImplementation.DynamicTree.TopLevelSupervisor

      def create(data_point) do
        data_point
        |> TopLevelSupervisor.add_child
      end

      def total_count do
        TopLevelSupervisor.count_children()
      end

      def get(key) do
        DataPoint.retrieve_state(key)
      end

      def update(new_state) do
        DataPoint.update_state(new_state)
      end

      def destroy(key) do
        key
        |> DataPoint.get_pid
        |> case do
          {:ok, pid} -> TopLevelSupervisor.remove_child(pid)
          error -> error
        end
      end

      def terminate_all do
        TopLevelSupervisor.terminate_all
      end
    end
  end
end
