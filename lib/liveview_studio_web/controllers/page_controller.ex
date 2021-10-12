defmodule LiveviewStudioWeb.PageController do
  use LiveviewStudioWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
