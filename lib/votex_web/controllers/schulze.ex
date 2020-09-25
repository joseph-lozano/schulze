defmodule VotexWeb.SchulzeController do
  use VotexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", [])
  end
end
