defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200)
    assert inertia_component(conn) == "Home"
  end
end
