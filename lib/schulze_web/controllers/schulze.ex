defmodule SchulzeWeb.SchulzeController do
  use SchulzeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", [])
  end
end
