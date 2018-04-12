defmodule ET.Cache do
  @moduledoc false

  alias ET.Cache.DomainLayer.Server

  alias __MODULE__.DomainLayer.Server
  def run do
    Server.create(:a, 1)
    Server.create(:b, 2)
    Server.create(:c, 3)
    Server.create(:d, 4)
    Server.create(:e, 5)
    Server.create(:f, 6)
  end
end
