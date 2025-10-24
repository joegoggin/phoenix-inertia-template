defmodule AppWeb.PageController do
  use AppWeb, :controller

  def home(conn, _params) do
    conn
    |> render_inertia("Home")
  end
end
